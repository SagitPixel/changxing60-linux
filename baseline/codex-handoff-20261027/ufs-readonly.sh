#!/bin/sh
set -eu
printf 'UFS boot log\n'
dmesg | grep -iE 'ufshcd|ufs-sprd|ufs-anlg|22000000.ufs|Attached SCSI|scsi host|\[sdc\]' | head -65
printf '\nRoot disk identification\n'
for u in /sys/class/block/*/uevent; do
 if grep -q '^PARTNAME=boot_b$' "$u"; then
  b=$(basename "$(dirname "$u")")
  disk=$(basename "$(dirname "$(readlink -f /sys/class/block/$b)")")
  echo "boot_b=$b disk=$disk"
 fi
done
[ -n "$disk" ]
O=77858865152
printf '\nRoot filesystem magic at recorded offset\n'
dd if=/dev/$disk bs=4096 skip=$((O/4096)) count=1 2>/dev/null | od -An -tx1 | head -8
L=$(losetup -f)
losetup -r -o "$O" "$L" /dev/$disk
printf '\nLoop device read-only state\n'
cat /sys/block/${L#/dev/}/ro
printf '\nSuperblock magic\n'
dd if="$L" bs=1 skip=1080 count=2 2>/dev/null | od -An -tx1
mkdir -p /mnt/codex-ufs-root
if mount -t ext4 -o ro,noload "$L" /mnt/codex-ufs-root; then
 mount | grep codex-ufs-root
 df -h /mnt/codex-ufs-root
 ls -la /mnt/codex-ufs-root
 for os in ubuntu openwrt; do
  echo "=== $os ==="
  cat /mnt/codex-ufs-root/$os/etc/os-release 2>/dev/null || true
  ls -l /mnt/codex-ufs-root/$os/sbin/init /mnt/codex-ufs-root/$os/lib/systemd/systemd 2>/dev/null || true
 done
 umount /mnt/codex-ufs-root
else
 losetup -d "$L"
 exit 1
fi
losetup -d "$L"
