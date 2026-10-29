from pathlib import Path
import subprocess, json, time

p = Path(__file__).resolve().parent
ssh = ['ssh', '-i', 'work/codex-7552n-key', '-o', 'BatchMode=yes',
       '-o', 'IdentitiesOnly=yes', '-o', 'UserKnownHostsFile=work/codex-known-hosts',
       'root@192.168.77.1']
v = '/opt/changxing60/bin/changxing60-voice-audio'
amp = '/sys/bus/i2c/devices/6-0058/profile'
def run(cmd): return subprocess.check_output(ssh + [cmd], stderr=subprocess.STDOUT, timeout=35)
assert b'+CLCC:' not in run('/opt/changxing60/bin/changxing60-at -t 4 AT+CLCC')
before = run(v + ' dump'); old_amp = run('cat ' + amp)
(p / 'voice-mixer-before.txt').write_bytes(before)
result = {}
try:
    result['start'] = run(v + ' start --band WB --volume 7').decode()
    time.sleep(2)
    result['pcm_playback'] = run('cat /proc/asound/card0/pcm5p/sub0/status').decode()
    result['pcm_capture'] = run('cat /proc/asound/card0/pcm5c/sub0/status').decode()
    result['amp_running'] = run('cat ' + amp).decode()
    assert 'RUNNING' in result['pcm_playback'] and 'RUNNING' in result['pcm_capture']
    assert '>Receiver' in result['amp_running']
finally:
    result['stop'] = run(v + ' stop').decode()
    after = run(v + ' dump')
    (p / 'voice-mixer-after.txt').write_bytes(after)
    result['mixer_restored'] = before == after
    result['amp_restored'] = old_amp == run('cat ' + amp)
    result['closed'] = run('head -1 /proc/asound/card0/pcm5p/sub0/status; head -1 /proc/asound/card0/pcm5c/sub0/status').decode()
    (p / 'voice-lifecycle.json').write_text(json.dumps(result, indent=2), encoding='utf8')
    print(json.dumps(result, indent=2))
assert result['mixer_restored'] and result['amp_restored'] and result['closed'].count('closed') == 2
