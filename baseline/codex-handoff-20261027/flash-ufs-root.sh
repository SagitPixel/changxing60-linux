#!/bin/sh
set -eu
IMG=/tmp/codex-boot-ufs-root.img
EXPECTED=bc0ae74fd4b67d98553b9b30eb6be4019d12543f15de28368ddcdb40424a7a7d
[ "$(sha256sum "$IMG" | cut -d' ' -f1)" = "$EXPECTED" ]
for u in /sys/class/block/*/uevent; do
 grep -q '^PARTNAME=boot_b$' "$u" && B=/dev/$(basename "$(dirname "$u")")
 grep -q '^PARTNAME=misc$' "$u" && M=/dev/$(basename "$(dirname "$u")")
done
[ "$B" = /dev/sdc40 ] && [ "$M" = /dev/sdc3 ]
[ "$(cat /sys/class/block/sdc40/size)" = 131072 ]
dd if="$IMG" of="$B" bs=1048576
sync
[ "$(sha256sum "$B" | cut -d' ' -f1)" = "$EXPECTED" ]
dd if=/etc/misc-bc-slot-b-trial.bin of="$M" bs=1 seek=2048 count=32 conv=notrunc
sync
dd if="$M" of=/tmp/codex-trial-readback.bin bs=1 skip=2048 count=32
cmp /etc/misc-bc-slot-b-trial.bin /tmp/codex-trial-readback.bin
echo VERIFIED_TRIAL_BOOT_READY
(sleep 2; reboot -f) >/tmp/codex-reboot.log 2>&1 &
