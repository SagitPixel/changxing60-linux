#!/usr/bin/env python3
"""Save read-only post-fix evidence through the phone's verified hotspot SSH key."""
from pathlib import Path
import json
import runpy
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
SSH = runpy.run_path(str(ROOT / 'tools/collect-system-errors.py'))['SSH']
SSH[-1] = 'root@192.168.8.1'
SSH[1:1] = ['-o', 'HostKeyAlias=192.168.77.1']
OUT = ROOT / 'baseline/power-fix-20261029/verified'
OUT.mkdir(parents=True, exist_ok=True)
COMMANDS = {
    'dmesg.txt': 'dmesg -r',
    'syslog.txt': 'logread',
    'stages.txt': 'cat /run/stages',
    'state.txt': '''uname -a; uptime; cat /proc/sys/kernel/random/boot_id
cat /sys/module/sprd_charger_manager/parameters/legacy_usb_extcon
cat /sys/module/sprd_charger_manager/parameters/legacy_board_thermal_zone
for d in /sys/class/power_supply/*; do cat "$d/uevent"; done
for d in /sys/class/thermal/thermal_zone*; do cat "$d/type" "$d/temp"; done
cat /sys/kernel/debug/devices_deferred
cat /proc/fb; ls /dev/dri
ip -4 addr; ip -4 route
crontab -l
ps w | grep '[c]harge-fix' || true
''',
    'network-test.txt': 'ping -c 3 -W 2 -I sipa_eth0 223.5.5.5',
}


def main():
    for name, cmd in COMMANDS.items():
        result = subprocess.run(SSH + [cmd], capture_output=True, timeout=25)
        (OUT / name).write_bytes(result.stdout)
        print(name, 'rc=', result.returncode, 'bytes=', len(result.stdout))
    cmd = '''for f in status online current_now voltage_now temp_ambient usb_type input_current_limit; do
echo "$f=$(cat /sys/class/power_supply/battery/$f)"; done'''
    samples = []
    for _ in range(4):
        result = subprocess.run(SSH + [cmd], capture_output=True, check=True, timeout=10)
        samples.append(dict(line.split('=', 1) for line in result.stdout.decode().splitlines()))
        time.sleep(2)
    (OUT / 'charging-samples.json').write_text(json.dumps(samples, indent=2))
    print(json.dumps(samples, indent=2))


if __name__ == '__main__':
    main()
