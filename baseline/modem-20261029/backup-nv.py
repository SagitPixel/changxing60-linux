from pathlib import Path
import subprocess, gzip, hashlib, json

p = Path(__file__).resolve().parent / 'nv-backup'
p.mkdir(exist_ok=True)
ssh = ['ssh', '-i', 'work/codex-7552n-key', '-o', 'BatchMode=yes',
       '-o', 'IdentitiesOnly=yes', '-o', 'UserKnownHostsFile=work/codex-known-hosts',
       'root@192.168.77.1']
def run(c): return subprocess.check_output(ssh + [c])
allowed = {'nr_fixnv1_a', 'nr_fixnv1_b', 'nr_fixnv2_a', 'nr_fixnv2_b',
           'nr_runtimenv1', 'nr_runtimenv2'}
lines = run('for u in /sys/class/block/*/uevent; do n=$(sed -n "s/^PARTNAME=//p" "$u"); case "$n" in nr_fixnv*|nr_runtimenv*) b=${u%/uevent}; echo "$n /dev/${b##*/} $(cat $b/size)";; esac; done').decode().splitlines()
assert {x.split()[0] for x in lines} == allowed
report = {}
for line in lines:
    name, dev, sectors = line.split()
    assert dev.startswith('/dev/sd') and int(sectors) * 512 < 64 * 1024 * 1024
    file = p / (name + '.img.gz')
    compressed = file.read_bytes() if file.exists() else run('test -b ' + dev + ' && gzip -c ' + dev)
    raw = gzip.decompress(compressed)
    assert len(raw) == int(sectors) * 512
    digest = hashlib.sha256(raw).hexdigest()
    assert run('sha256sum ' + dev).split()[0].decode() == digest
    if not file.exists():
        file.write_bytes(compressed)
    report[name] = {'device': dev, 'bytes': len(raw), 'sha256_raw': digest,
                    'sha256_gzip': hashlib.sha256(file.read_bytes()).hexdigest()}
(p / 'manifest.json').write_text(json.dumps(report, indent=2), encoding='utf8')
print('NV partitions backed up read-only:', len(report))
