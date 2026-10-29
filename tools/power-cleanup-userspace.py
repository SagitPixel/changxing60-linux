#!/usr/bin/env python3
"""Back up and retire the obsolete 5.4 charge-fix job on a 6.18 device."""
import hashlib
import argparse
from pathlib import Path
import runpy
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SSH = runpy.run_path(str(ROOT / 'tools/collect-system-errors.py'))['SSH']


def remote(cmd, data=None):
    return subprocess.run(SSH + [cmd], input=data, capture_output=True, check=True).stdout


def sha(blob):
    return hashlib.sha256(blob).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', default='192.168.77.1')
    args = parser.parse_args()
    if args.host != '192.168.77.1':
        SSH[-1] = 'root@' + args.host
        SSH[1:1] = ['-o', 'HostKeyAlias=192.168.77.1']
    assert remote('uname -r').startswith(b'6.'), 'Cleanup is only for Linux 6.18'
    backup = ROOT / 'baseline/power-fix-20261029/userspace-before'
    backup.mkdir(parents=True, exist_ok=True)
    path = '/opt/changxing60/bin/charge-fix'
    old = remote('cat ' + path)
    cron = remote('cat /etc/crontabs/root')
    hardware_path = '/etc/init.d/changxing60-hw'
    hardware_old = remote('cat ' + hardware_path)
    hardware_new = (ROOT / 'rootfs/overlay/etc/init.d/changxing60-hw').read_bytes().replace(b'\r\n', b'\n')
    # This migration only accepts the known boot-script guard change.
    old_guard = b"\tif [ -f /etc/crontabs/root ] || [ -d /etc/crontabs ]; then\n\t\tgrep -q 'changxing60/bin/charge-fix'"
    new_guard = b"\t# 6.18 uses native charger-manager; the register-pinning job is 5.4-only.\n\tif [ \"$(uname -r | cut -d. -f1)\" != 6 ] && { [ -f /etc/crontabs/root ] || [ -d /etc/crontabs ]; }; then\n\t\tgrep -q 'changxing60/bin/charge-fix'"
    assert hardware_old == hardware_new or hardware_old.replace(old_guard, new_guard, 1) == hardware_new, 'Unexpected boot script changes'
    for name, data in [('charge-fix', old), ('crontab-root', cron), ('changxing60-hw', hardware_old)]:
        if not (backup / name).exists():
            (backup / name).write_bytes(data)
    script = (ROOT / 'rootfs/overlay/opt/changxing60/bin/charge-fix').read_bytes().replace(b'\r\n', b'\n')
    job = b'* * * * * /opt/changxing60/bin/charge-fix >/dev/null 2>&1'
    new_cron = b''.join(line for line in cron.splitlines(keepends=True) if line.strip() != job)
    for filename, blob in [('charge-fix-618', script), ('crontab-power-fixed', new_cron),
                           ('changxing60-hw-power-fixed', hardware_new)]:
        remote('cat > /tmp/' + filename, blob)
        assert remote('sha256sum /tmp/' + filename).split()[0].decode() == sha(blob)
    # Refuse to deploy over concurrent changes. The old implementation stays on
    # persistent storage for recovery and for an intentional 5.4 fallback.
    cmd = f'''set -eu
test "$(sha256sum {path} | cut -d' ' -f1)" = {sha(old)}
test "$(sha256sum /etc/crontabs/root | cut -d' ' -f1)" = {sha(cron)}
test "$(sha256sum {hardware_path} | cut -d' ' -f1)" = {sha(hardware_old)}
mkdir -p /root/changxing60-backup/power-userspace
cp -p /etc/crontabs/root /root/changxing60-backup/power-userspace/crontab-root-before
if [ ! -e {path}.legacy-5.4 ]; then cp -p {path} {path}.legacy-5.4; fi
if [ ! -e /root/changxing60-backup/power-userspace/changxing60-hw-before ]; then cp -p {hardware_path} /root/changxing60-backup/power-userspace/changxing60-hw-before; fi
sh -n /tmp/changxing60-hw-power-fixed
cp /tmp/changxing60-hw-power-fixed {hardware_path}
chmod 755 {hardware_path}
cp /tmp/charge-fix-618 {path}
chmod 755 {path}
crontab /tmp/crontab-power-fixed
sha256sum {path}
crontab -l
'''
    print(remote(cmd).decode())


if __name__ == '__main__':
    main()
