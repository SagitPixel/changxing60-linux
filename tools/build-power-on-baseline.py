#!/usr/bin/env python3
"""Add the 7552N power stack without replacing a validated kernel or other modules."""
import argparse
import hashlib
import importlib.util
from pathlib import Path
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('repack', ROOT / 'boot/repack-ramdisk.py')
repack = importlib.util.module_from_spec(spec)
spec.loader.exec_module(repack)
POWER = ['sprd_battery_info.ko', 'sprd-charger-manager.ko',
         'ump96xx_fuel_gauge.ko', 'bq2560x-charger.ko']


def unpack(path):
    blob = path.read_bytes()
    assert blob[:8] == b'ANDROID!'
    ks, rs = struct.unpack_from('<II', blob, 8)
    off = repack.PAGE + (ks + repack.PAGE - 1) // repack.PAGE * repack.PAGE
    cpio = subprocess.run(repack.LZ4 + ['-d', '-c'], input=blob[off:off + rs],
                          capture_output=True, check=True).stdout
    entries, _ = repack.read_cpio(cpio)
    return blob[repack.PAGE:repack.PAGE + ks], {e[0]: e[4] for e in entries}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--legacy-charging', action='store_true',
                        help='Enable 7552N EXTCON_USB detection and real board temperature')
    args = parser.parse_args()
    kernel, files = unpack(args.base)
    original = files['etc/module-order'].decode().splitlines()
    # Preserve every existing non-power module and its order, including display,
    # Wi-Fi and modem. Charger-manager supplies cm_notify_event to the gauge.
    order = POWER + [m for m in original if m not in POWER and m != 'aw32257_charger.ko']
    with tempfile.TemporaryDirectory(prefix='7552n-power-') as tmp:
        order_file = Path(tmp) / 'module-order'
        order_file.write_text('\n'.join(order) + '\n')
        cmd = ['python3', str(ROOT / 'boot/repack-ramdisk.py'), '--base', str(args.base),
               '--out', str(args.out), '--set', f'etc/module-order={order_file}']
        expected_init = files['init']
        if args.legacy_charging:
            assert hashlib.sha256(kernel).hexdigest() == '197075a80199c7b9554a42561bd6edaf784f0c35222b294aa5a3d6e3b307033a', 'Unverified kernel baseline'
            marker = b'        6.*:wcn_bsp.ko) set -- keep_power_on=1 ;;'
            addition = b'        6.*:sprd-charger-manager.ko) set -- legacy_usb_extcon=1 legacy_board_thermal_zone=board-thmzone ;;\n'
            assert expected_init.count(marker) == 1, 'Unknown init loader'
            if addition not in expected_init:
                expected_init = expected_init.replace(marker, addition + marker, 1)
            init_file = Path(tmp) / 'init'
            init_file.write_bytes(expected_init)
            cmd += ['--set', f'init={init_file}']
        for name in POWER:
            target = 'linux-modules/' + name
            source = ROOT / 'work/mod618' / name
            assert source.is_file(), source
            cmd += ['--set' if target in files else '--add', f'{target}={source}']
        subprocess.run(cmd, check=True)
    new_kernel, new_files = unpack(args.out)
    assert new_kernel == kernel, 'kernel changed'
    permitted = {'etc/module-order'} | {'linux-modules/' + m for m in POWER}
    if args.legacy_charging:
        permitted.add('init')
    assert {n for n in files if files[n] != new_files.get(n)} <= permitted
    assert set(new_files) - set(files) <= permitted
    assert new_files['init'] == expected_init, 'Unexpected init change'
    for name in order:
        if name and not name.startswith('#'):
            assert 'linux-modules/' + name in new_files, name
    print('Verified: kernel and all unrelated files preserved; init matches requested options')
    print('Kernel SHA256:', hashlib.sha256(kernel).hexdigest())
    print('Image SHA256:', hashlib.sha256(args.out.read_bytes()).hexdigest())


if __name__ == '__main__':
    main()
