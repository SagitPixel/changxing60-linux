#!/bin/sh
set -eu
L=$(losetup -f)
losetup -o 77858865152 "$L" /dev/sdc
mkdir -p /mnt/codex-ufs-root
mount -t ext4 -o noatime "$L" /mnt/codex-ufs-root
F=/mnt/codex-ufs-root/.changxing60/codex-ufs-check-20261028.bin
[ ! -e "$F" ]
dd if=/dev/urandom of="$F" bs=1048576 count=8
sync
EXPECTED=$(sha256sum "$F" | cut -d' ' -f1)
echo "expected=$EXPECTED"
umount /mnt/codex-ufs-root
losetup -d "$L"
L=$(losetup -f)
losetup -r -o 77858865152 "$L" /dev/sdc
mount -t ext4 -o ro,noload "$L" /mnt/codex-ufs-root
ACTUAL=$(sha256sum "$F" | cut -d' ' -f1)
echo "after-unmount-remount=$ACTUAL"
[ "$ACTUAL" = "$EXPECTED" ]
echo UFS_RW_CHECK_PASS
R=/mnt/codex-ufs-root/openwrt
printf '\nRootfs startup configuration\n'
ls "$R/etc/rc.d"
cat /mnt/codex-ufs-root/.changxing60/boot-os 2>/dev/null || true
cat "$R/etc/changxing60/default-boot" 2>/dev/null || true
for f in "$R/etc/init.d/changxing60-audio-up" "$R/etc/init.d/changxing60-modemd" "$R/etc/init.d/changxing60-network"; do
 [ ! -f "$f" ] || { echo "$f"; head -65 "$f"; }
done
printf '\nNetwork config without keys\n'
grep -E '^config|option (device|ifname|proto|ipaddr|netmask|type|name)' "$R/etc/config/network" || true
umount /mnt/codex-ufs-root
losetup -d "$L"
L=$(losetup -f)
losetup -o 77858865152 "$L" /dev/sdc
mount -t ext4 -o noatime "$L" /mnt/codex-ufs-root
[ -f "$F" ] && rm "$F"
sync
umount /mnt/codex-ufs-root
losetup -d "$L"
echo UFS_CHECK_FILE_REMOVED
