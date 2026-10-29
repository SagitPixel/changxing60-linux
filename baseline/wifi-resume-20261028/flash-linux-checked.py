from pathlib import Path
import subprocess,hashlib,json,struct,zlib,shlex,sys
HERE=Path(__file__).resolve().parent
ssh=['ssh','-i','work/codex-7552n-key','-o','BatchMode=yes','-o','IdentitiesOnly=yes','-o','UserKnownHostsFile=work/codex-known-hosts','root@192.168.77.1']
def root(c): return subprocess.run(ssh+[c],check=True,capture_output=True).stdout
def sha(b): return hashlib.sha256(b).hexdigest()
image=HERE/(sys.argv[1] if len(sys.argv)>1 else 'boot-wifi-keep.img'); blob=image.read_bytes(); bcb=(HERE/'bcb-trial.bin').read_bytes()
assert len(blob)==67108864 and blob[:8]==b'ANDROID!'
assert sha(blob)==json.loads(image.with_suffix('.json').read_text(encoding='utf8'))['sha256']
assert len(bcb)==32 and zlib.crc32(bcb[:28])&0xffffffff==struct.unpack_from('<I',bcb,28)[0]
assert bcb[:4]==b'_b\0\0' and bcb[12]&128 and not bcb[14]&128 and (bcb[14]>>4)&7==2
parts=root('for u in /sys/class/block/*/uevent; do n=$(sed -n "s/^PARTNAME=//p" "$u"); case "$n" in boot_b|misc) b=${u%/uevent}; echo "$n /dev/${b##*/}";; esac; done').decode().splitlines()
parsed=[x.split() for x in parts];assert len(parsed)==2 and len({x[0] for x in parsed})==2
parts=dict(parsed);boot=parts['boot_b'];misc=parts['misc']
assert root('test -b '+boot+' && test -b '+misc+' && cat /sys/class/block/'+boot.split('/')[-1]+'/size').strip()==b'131072'
before=root('cat '+misc);assert before==(HERE/'misc-restored.img').read_bytes(), 'misc differs from restored baseline; stop'
(HERE/(image.stem+'-misc-before.img')).write_bytes(before)
for src,dst in [(image,'/root/codex-wifi-keep.img'),(HERE/'bcb-trial.bin','/root/codex-wifi-trial.bin'),(HERE/'misc-restored.img','/root/codex-misc-restored-backup.img')]:
 subprocess.run(ssh+['cat > '+dst],input=src.read_bytes(),check=True)
 assert root('sha256sum '+dst).split()[0].decode()==sha(src.read_bytes())
# Stop only the identified log recorder, which otherwise writes boot_b's log tail during verification.
for line in root('ps w | grep "[e]arly-recorder 420" || true').decode().splitlines():
 pid=line.split()[0]
 if pid.isdecimal() and b'/opt/changxing60/bin/early-recorder\000420' in root('cat /proc/'+pid+'/cmdline'):
  root('kill '+pid)
root('sleep 1; dd if=/root/codex-wifi-keep.img of='+boot+' bs=4194304 count=16 conv=notrunc && sync')
assert root('sha256sum '+boot).split()[0].decode()==sha(blob), 'boot_b readback mismatch; misc untouched'
assert root('cat '+misc)==before
root('dd if=/root/codex-wifi-trial.bin of='+misc+' bs=1 seek=2048 count=32 conv=notrunc && sync')
after=root('cat '+misc);(HERE/(image.stem+'-misc-after.img')).write_bytes(after)
assert len(after)==len(before) and after[:2048]==before[:2048] and after[2080:]==before[2080:]
assert after[2048:2080]==bcb
report={'boot':boot,'misc':misc,'image_sha256':sha(blob),'outside_bcb_unchanged':True,'changed_offsets':[i for i,(a,b) in enumerate(zip(before,after)) if a!=b],'reboot_requested':False}
(HERE/(image.stem+'-flash-verification.json')).write_text(json.dumps(report,indent=2),encoding='utf8');print(json.dumps(report,indent=2))
