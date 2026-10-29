from pathlib import Path
import subprocess, hashlib, sys

p = Path(__file__).resolve().parent
name = sys.argv[1]
assert name in {'sprd-sipc-virt-bus', 'sbuf_bridge', 'sblock_bridge', 'slog_bridge',
                'sipa-sys', 'sipa-core', 'sipa_eth', 'sipa-dele', 'sipa_usb'}
ssh = ['ssh', '-i', 'work/codex-7552n-key', '-o', 'ConnectTimeout=8', '-o', 'BatchMode=yes',
       '-o', 'IdentitiesOnly=yes', '-o', 'UserKnownHostsFile=work/codex-known-hosts',
       'root@192.168.77.1']
blob = (p / 'modules' / (name + '.ko')).read_bytes()
dest = '/root/codex-modem-618/' + name + '.ko'
subprocess.run(ssh + ['cat > ' + dest], input=blob, check=True)
assert subprocess.check_output(ssh + ['sha256sum ' + dest]).split()[0].decode() == hashlib.sha256(blob).hexdigest()
result = subprocess.run(ssh + ['insmod ' + dest], capture_output=True)
(p / (name + '-load.txt')).write_bytes(result.stdout + result.stderr)
print(name, 'load_rc', result.returncode, result.stderr.decode(errors='replace'))
raise SystemExit(result.returncode)
