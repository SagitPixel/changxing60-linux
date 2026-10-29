#!/usr/bin/env python3
"""Read-only SSH collection of live 7552N diagnostics; never clears log buffers."""
from datetime import datetime
from pathlib import Path
import json
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SSH = ['ssh', '-i', str(ROOT / 'work/codex-7552n-key'), '-o', 'BatchMode=yes',
       '-o', 'ConnectTimeout=6', '-o', 'StrictHostKeyChecking=yes',
       '-o', 'UserKnownHostsFile=' + str(ROOT / 'work/codex-known-hosts'),
       'root@192.168.77.1']
COMMANDS = {
    'dmesg.txt': 'dmesg -r',
    'syslog.txt': 'logread',
    'stages.txt': 'cat /run/stages',
    'processes.txt': 'ps w; cat /proc/meminfo; cat /proc/loadavg; df -h',
    'services.json': 'ubus call service list',
    'state.txt': '''uname -a; uptime; date; cat /proc/sys/kernel/tainted
echo DEFERRED; cat /sys/kernel/debug/devices_deferred
echo POWER; for d in /sys/class/power_supply/*; do cat "$d/uevent"; done
echo NET; ip -s link; ip -4 addr; ip -4 route
echo SOUND; cat /proc/asound/cards; cat /proc/asound/pcm
echo DISPLAY; cat /proc/fb; ls -l /dev/dri
echo MODULES; cat /proc/modules
echo CRON; cat /etc/crontabs/root
echo BOOTDIAG; ls -l /tmp/*log /var/log/* /run/*log /root/*log 2>/dev/null
''',
    'recent-files.txt': '''for f in /tmp/changxing60-display-modules.log /root/audio-load.log /root/audio-route.log /root/voice-audio.log /run/modem_control.log; do
if [ -f "$f" ]; then echo "FILE $f"; tail -n 120 "$f"; fi; done
''',
    'pstore-summary.txt': '''for f in /sys/fs/pstore/*; do echo "FILE $f"; head -n 12 "$f"; grep -Ei 'Linux version|panic|Oops|SError|Call trace' "$f" | tail -n 20; done''',
}


def main():
    out = ROOT / 'baseline' / ('system-audit-' + datetime.now().strftime('%Y%m%d-%H%M%S'))
    out.mkdir(parents=True)
    metadata = {}
    for name, cmd in COMMANDS.items():
        r = subprocess.run(SSH + [cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30)
        (out / name).write_bytes(r.stdout)
        metadata[name] = {'rc': r.returncode, 'bytes': len(r.stdout),
                          'stderr': r.stderr.decode(errors='replace')}
    (out / 'collection.json').write_text(json.dumps(metadata, indent=2))
    print(out)
    print(json.dumps(metadata, indent=2))


if __name__ == '__main__':
    main()
