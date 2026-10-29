from pathlib import Path
import subprocess, tarfile, hashlib, json, shutil

root = Path('/k/linux')
repo = Path('/repo')
out = repo / 'baseline/wifi-verified-20261029'
out.mkdir(exist_ok=True)
head = subprocess.check_output(['git', '-C', str(root), 'rev-parse', 'HEAD'], text=True).strip()
changed = subprocess.check_output(['git', '-C', str(root), 'diff', '--name-only', '-z']).split(b'\0')
extra = subprocess.check_output(['git', '-C', str(root), 'ls-files', '--others', '--exclude-standard', '-z']).split(b'\0')
names = sorted(set(x.decode() for x in changed + extra if x))
manifest = {}
with tarfile.open(out / 'kernel-source-overlay.tar.gz', 'w:gz') as archive:
    for name in names:
        file = root / name
        if not file.exists():
            manifest[name] = {'deleted': True}
            continue
        assert file.resolve().is_relative_to(root) and file.stat().st_size < 8 * 1024 * 1024
        archive.add(file, arcname=name, recursive=False)
        manifest[name] = {'sha256': hashlib.sha256(file.read_bytes()).hexdigest()}
(out / 'kernel-base-and-files.json').write_text(json.dumps({'base': head, 'files': manifest}, indent=2), encoding='utf8')
(out / 'ALL-CHANGES.patch').write_bytes(subprocess.check_output(['git', '-C', str(root), 'diff', '--binary']))
shutil.copy2('/k/build/.config', out / 'kernel.config')
src = repo / 'baseline/wifi-resume-20261028'
for name in ['boot-wifi-ipd.img', 'boot-wifi-ipd.json', 'boot-wifi-ipd-flash-verification.json',
             'wcn_bsp-ipd.ko', 'sprd_wlan_combo-ipd.ko', 'init', 'bcb-android.bin', 'bcb-trial.bin',
             'misc-restored.img', 'ipd-5g-final-validation.txt', 'normal-ini-sg-client-ping.txt',
             'ipd-early-recorder.txt']:
    shutil.copy2(src / name, out / name)
paths = ['drivers/unisoc_platform/sprdwcn/platform/wcn_boot.c',
         'drivers/unisoc_platform/sprdwcn/platform/gnss_dump.c',
         'drivers/unisoc_platform/sprd_wlan_combo/sc2355/hw_param.c',
         'include/misc/marlin_platform.h']
patch = subprocess.check_output(['git', '-C', str(root), 'diff', '--'] + paths)
(repo / 'kernel/patches/wcn-7552n-resources-ipd.patch').write_bytes(patch)
(repo / 'kernel/patches/mmc-sdhci-wifi-power.patch').write_bytes(
    subprocess.check_output(['git', '-C', str(root), 'diff', '--', 'drivers/mmc/host/sdhci-sprd.c']))
subprocess.run(['git', '-C', str(root), 'apply', '--reverse', '--check', str(repo / 'kernel/patches/wcn-7552n-resources-ipd.patch')], check=True)
for name in ['wcn_bsp', 'sprd_wlan_combo']:
    old = repo / f'work/mod618/{name}.ko'
    if old.exists():
        shutil.copy2(old, src / f'{name}-work-mod618-before.ko')
    shutil.copy2(src / f'{name}-ipd.ko', old)
(out / 'SHA256SUMS.txt').write_text(''.join(
    f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.name}\n'
    for p in sorted(out.iterdir()) if p.is_file() and p.name != 'SHA256SUMS.txt'), encoding='utf8')
print(json.dumps({'base': head, 'source_files': len(manifest), 'verified_dir': str(out)}, indent=2))
