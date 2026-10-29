from pathlib import Path
import subprocess, hashlib, json

p = Path(__file__).resolve().parent
ssh = ['ssh', '-i', 'work/codex-7552n-key', '-o', 'BatchMode=yes',
       '-o', 'IdentitiesOnly=yes', '-o', 'UserKnownHostsFile=work/codex-known-hosts',
       'root@192.168.77.1']
def run(c):
    return subprocess.check_output(ssh + [c])
assert run('uname -r').strip() == b'6.18.54-7552n-probe1+'
run('mkdir -p /root/codex-modem-618')
report = {}
for name in ['sprd_modem_loader', 'spipe', 'spool']:
    blob = (p / 'modules' / f'{name}.ko').read_bytes()
    dst = f'/root/codex-modem-618/{name}.ko'
    subprocess.run(ssh + ['cat > ' + dst], input=blob, check=True)
    digest = hashlib.sha256(blob).hexdigest()
    assert run('sha256sum ' + dst).split()[0].decode() == digest
    report[name] = {'sha256': digest}
    report[name]['load'] = run('insmod ' + dst + ' 2>&1; echo rc=$?').decode()
(p / 'control-module-load.json').write_text(json.dumps(report, indent=2), encoding='utf8')
print(json.dumps(report, indent=2))
