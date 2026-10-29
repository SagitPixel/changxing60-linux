from pathlib import Path
import subprocess, hashlib, json

p = Path(__file__).resolve().parent
ssh = ['ssh', '-i', 'work/codex-7552n-key', '-o', 'BatchMode=yes',
       '-o', 'IdentitiesOnly=yes', '-o', 'UserKnownHostsFile=work/codex-known-hosts',
       'root@192.168.77.1']
def run(cmd):
    return subprocess.check_output(ssh + [cmd])

release = run('uname -r').decode().strip()
assert release == '6.18.54-7552n-probe1+'
report = {}
for name in ['wcn_bsp', 'sprd_wlan_combo']:
    data = (p / f'{name}-ipd.ko').read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    dest = f'/lib/modules/{release}/{name}.ko'
    backup = f'/root/codex-wifi-backup/rootfs-{name}-before-ipd.ko'
    run(f'if [ -f {dest} ] && [ ! -e {backup} ]; then cp -p {dest} {backup}; fi')
    subprocess.run(ssh + [f'cat > {dest}.ipd-new'], input=data, check=True)
    assert run(f'sha256sum {dest}.ipd-new').split()[0].decode() == digest
    run(f'chmod 644 {dest}.ipd-new && mv {dest}.ipd-new {dest}')
    report[dest] = digest
(p / 'rootfs-module-sync.json').write_text(json.dumps(report, indent=2), encoding='utf8')
print(json.dumps(report, indent=2))
