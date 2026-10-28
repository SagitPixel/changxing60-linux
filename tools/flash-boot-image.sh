#!/bin/sh
# Flash boot_b + the trial-B BCB from inside Linux, using the partition names
# rather than a hard-coded sda/sdb/sdc: the UFS LUN enumeration order on this
# board changes between boots, and writing sda40 on a boot where sda is another
# LUN is how the boot_b got corrupted once.
#
# usage: sh flash-boot-image.sh <boot.img> <bcb32.bin>
set -eu
export PATH="$PATH:/opt/changxing60/busybox-bin"

IMG=${1:?usage: flash-boot-image.sh boot.img bcb.bin}
BCB=${2:?usage: flash-boot-image.sh boot.img bcb.bin}

find_part() {
    name=$1
    for u in /sys/class/block/*/uevent; do
        [ "$(sed -n 's/^PARTNAME=//p' "$u")" = "$name" ] || continue
        echo "/dev/$(basename "$(dirname "$u")")"
        return 0
    done
    return 1
}

BOOT=$(find_part boot_b) || { echo "boot_b partition not found" >&2; exit 1; }
MISC=$(find_part misc) || { echo "misc partition not found" >&2; exit 1; }
echo "boot_b=$BOOT misc=$MISC"

[ -f "$IMG" ] && [ -f "$BCB" ] || { echo "input file missing" >&2; exit 1; }
[ "$(wc -c < "$BCB")" -eq 32 ] || { echo "BCB must be exactly 32 bytes" >&2; exit 1; }
[ "$(dd if="$IMG" bs=8 count=1 2>/dev/null)" = 'ANDROID!' ] || { echo "invalid boot image header" >&2; exit 1; }
PART_BYTES=$(( $(cat "/sys/class/block/${BOOT#/dev/}/size") * 512 ))
[ "$(wc -c < "$IMG")" -eq "$PART_BYTES" ] || { echo "image must match boot_b size" >&2; exit 1; }
# Keep slot B unconfirmed with attempts remaining, preserving Android fallback.
B_FLAGS=$(od -An -tu1 -j 14 -N 1 "$BCB" | tr -d ' ')
[ "$((B_FLAGS & 128))" -eq 0 ] && [ "$(((B_FLAGS >> 4) & 7))" -gt 0 ] || {
    echo "BCB is not an unconfirmed trial-B record" >&2; exit 1;
}
EXPECTED=$(sha256sum "$IMG" | cut -d' ' -f1)

dd if="$IMG" of="$BOOT" bs=1M 2>/dev/null
sync
ACTUAL=$(sha256sum "$BOOT" | cut -d' ' -f1)
echo "image: $EXPECTED"
echo "target: $ACTUAL"
[ "$ACTUAL" = "$EXPECTED" ] || { echo "boot_b readback mismatch; trial not armed" >&2; exit 1; }

dd if="$BCB" of="$MISC" bs=1 seek=2048 count=32 conv=notrunc 2>/dev/null
sync
echo "bcb: $(dd if="$MISC" bs=1 skip=2048 count=32 2>/dev/null | md5sum | cut -d' ' -f1)"
READBACK=/tmp/changxing60-flash-bcb.$$
dd if="$MISC" of="$READBACK" bs=1 skip=2048 count=32 2>/dev/null
cmp -s "$READBACK" "$BCB" || { echo "BCB readback mismatch" >&2; exit 1; }
rm "$READBACK"
echo "armed; reboot to boot it"
