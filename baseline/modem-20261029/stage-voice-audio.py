from pathlib import Path
import subprocess, hashlib

p = Path(__file__).resolve().parent
ssh = ['ssh', '-i', 'work/codex-7552n-key', '-o', 'BatchMode=yes',
       '-o', 'IdentitiesOnly=yes', '-o', 'UserKnownHostsFile=work/codex-known-hosts',
       'root@192.168.77.1']
def run(cmd): return subprocess.check_output(ssh + [cmd])
assert b'+CLCC:' not in run('/opt/changxing60/bin/changxing60-at -t 4 AT+CLCC')
src = Path('rootfs/overlay/opt/changxing60/bin/changxing60-voice-audio')
dest = '/opt/changxing60/bin/changxing60-voice-audio'
run(f'test -e /root/codex-modem-618/voice-audio-before || cp -p {dest} /root/codex-modem-618/voice-audio-before')
subprocess.run(ssh + ['cat > ' + dest + '.new'], input=src.read_bytes(), check=True)
assert run('sha256sum ' + dest + '.new').split()[0].decode() == hashlib.sha256(src.read_bytes()).hexdigest()
run(f'chmod 755 {dest}.new && mv {dest}.new {dest}')
print('voice audio updated; no call in progress')
