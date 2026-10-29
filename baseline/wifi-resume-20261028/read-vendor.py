from pathlib import Path
import subprocess,json
p=Path(__file__).resolve().parent;layout=json.loads((p/'super-layout.json').read_text(encoding='utf8'))
ssh=['ssh','-i','work/codex-7552n-key','-o','BatchMode=yes','-o','IdentitiesOnly=yes','-o','UserKnownHostsFile=work/codex-known-hosts','root@192.168.77.1']
with (p/'vendor_a.img').open('wb') as out:
 for count,typ,start,dev in layout['vendor_a']:
  assert typ==0 and dev==0 and start%8==0 and count%8==0
  cmd=f'dd if=/dev/sda49 bs=4096 skip={start//8} count={count//8} 2>/dev/null'
  r=subprocess.run(ssh+[cmd],stdout=out,stderr=subprocess.PIPE,check=True)
assert (p/'vendor_a.img').stat().st_size==sum(x[0]*512 for x in layout['vendor_a'])
print('vendor extracted read-only', (p/'vendor_a.img').stat().st_size)
