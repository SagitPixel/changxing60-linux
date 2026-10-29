#!/bin/sh
# Arm one trial boot of slot b from inside Linux: write boot_b, then the 32-byte
# bootloader_control record at offset 0x800 of misc. Device-side; boot_a,
# vendor_boot_a and every other byte of misc are never written.
#
# usage: BOOT_SHA256=<sha256 of img> BCB_SHA256=<sha256 of bcb> \
#            sh flash-boot-image.sh <boot.img> <bcb32.bin>
#
# env:
#   BOOT_SHA256     required. The image is written only if it hashes to this.
#   BCB_SHA256      required. The record is written only if it hashes to this AND
#                   is the canonical trial-B record this device boots with, so a
#                   truncated, stale or hand-edited record cannot be armed.
#   LIVE_BCB_SHA256 optional. Extra gate: the live control block must hash to this.
#   BACKUP_DIR      misc backup destination (default /root/changxing60-backup); it
#                   must not be a ramdisk, the backup has to survive the reboot.
#   DRY_RUN=1       validate and back up, print the writes, change nothing.
#
# Order of operations: validate every input, back up the whole 1 MiB misc and read
# it back, then write boot_b, then the record with an explicit count=32, then prove
# the 32 bytes match and that no other byte of misc moved. A post-write mismatch
# restores the backup. Nothing here reboots.
set -eu
export PATH="$PATH:/opt/changxing60/busybox-bin"

IMG=${1:?usage: BOOT_SHA256=... BCB_SHA256=... flash-boot-image.sh boot.img bcb32.bin}
BCB=${2:?usage: BOOT_SHA256=... BCB_SHA256=... flash-boot-image.sh boot.img bcb32.bin}
BOOT_SHA256=${BOOT_SHA256:?BOOT_SHA256 is required (expected sha256 of the boot image)}
BCB_SHA256=${BCB_SHA256:?BCB_SHA256 is required (expected sha256 of the control block)}
LIVE_BCB_SHA256=${LIVE_BCB_SHA256:-}
DRY_RUN=${DRY_RUN:-}
BACKUP_DIR=${BACKUP_DIR:-/root/changxing60-backup}

# Records shipped in the ramdisk (etc/misc-bc-slot-*.bin). The trial-B record is
# slot _b, slot a 14/7/successful, slot b 15/2/not-successful: LK decrements tries
# to 1 and boots b, and rolls back to a if that boot fails.
MISC_BC_A_SHA=56290070e590c073d535b20d4133a51dd7c0dae415a8ae4b474a4ecb7ffc3ebb
MISC_BC_B_SHA=9e2f7c07eba8efb341bcefc09709fc210e0f0e27f097d74163a9d18f271d48e2
MISC_BYTES_EXPECTED=$((1024 * 1024))

say() { echo "$*" >&2; }
die() { echo "ABORT: $*" >&2; exit 1; }

find_part() {
    name=$1
    found=
    for u in /sys/class/block/*/uevent; do
        [ "$(sed -n 's/^PARTNAME=//p' "$u" 2>/dev/null)" = "$name" ] || continue
        block=$(basename "$(dirname "$u")")
        node=
        for cand in "/dev/block/$block" "/dev/$block"; do
            [ -b "$cand" ] && { node=$cand; break; }
        done
        [ -n "$node" ] || { say "partition $name ($block) has no block device node"; return 1; }
        [ -z "$found" ] || { say "PARTNAME=$name matches both $found and $node"; return 1; }
        found=$node
    done
    [ -n "$found" ] || { say "partition $name not found"; return 1; }
    echo "$found"
}

pbytes() {
    s=$(cat "/sys/class/block/$(basename "$1")/size" 2>/dev/null) || return 1
    echo $((s * 512))
}

file_sha() { sha256sum "$1" | cut -d' ' -f1; }

flush() {
    sync
    command -v blockdev >/dev/null 2>&1 && blockdev --flushbufs "$1" 2>/dev/null
    sync
    return 0
}

raw_eq() {  # raw_eq FILE OFFSET COUNT STRING
    [ "$(dd if="$1" bs=1 skip="$2" count="$3" 2>/dev/null)" = "$4" ]
}

zeros_at() {  # zeros_at FILE OFFSET COUNT
    [ "$(dd if="$1" bs=1 skip="$2" count="$3" 2>/dev/null | tr -d '\000' | wc -c)" -eq 0 ]
}

check_bcb_struct() {  # check_bcb_struct FILE LABEL  -- structure only, no policy
    bcf=$1
    bcwhat=$2
    [ "$(wc -c < "$bcf")" -eq 32 ] || { say "$bcwhat: not 32 bytes"; return 1; }
    case "$(dd if="$bcf" bs=1 count=2 2>/dev/null)" in
        _a|_b) ;;
        *) say "$bcwhat: slot_suffix is not _a/_b"; return 1 ;;
    esac
    zeros_at "$bcf" 2 2 || { say "$bcwhat: slot_suffix has trailing garbage"; return 1; }
    raw_eq "$bcf" 4 4 BCAB || { say "$bcwhat: magic is not BCAB"; return 1; }
    zeros_at "$bcf" 13 1 || { say "$bcwhat: slot a reserved byte is not zero"; return 1; }
    zeros_at "$bcf" 15 1 || { say "$bcwhat: slot b reserved byte is not zero"; return 1; }
    zeros_at "$bcf" 20 8 || { say "$bcwhat: reserved bytes 20..27 are not zero"; return 1; }
    return 0
}

# --- inputs -----------------------------------------------------------------
[ -f "$IMG" ] || die "no such file: $IMG"
[ -f "$BCB" ] || die "no such file: $BCB"
[ "$(wc -c < "$BCB")" -eq 32 ] || die "$BCB is not exactly 32 bytes"
[ "$(dd if="$IMG" bs=8 count=1 2>/dev/null)" = 'ANDROID!' ] || die "$IMG has no ANDROID! boot header"

img_sha=$(file_sha "$IMG")
bcb_sha=$(file_sha "$BCB")
[ "$img_sha" = "$BOOT_SHA256" ] || die "$IMG hashes to $img_sha, expected $BOOT_SHA256"
[ "$bcb_sha" = "$BCB_SHA256" ] || die "$BCB hashes to $bcb_sha, expected $BCB_SHA256"
check_bcb_struct "$BCB" "$BCB" || die "$BCB is not a readable bootloader_control record"
[ "$bcb_sha" = "$MISC_BC_B_SHA" ] ||
    die "$BCB is not the canonical trial-B record (slot b 15/2/not-successful)"
raw_eq "$BCB" 0 2 _b || die "$BCB has slot suffix $(dd if="$BCB" bs=1 count=2 2>/dev/null), expected _b"

# --- target partitions ------------------------------------------------------
BOOT=$(find_part boot_b) || die "boot_b partition not found"
MISC=$(find_part misc) || die "misc partition not found"
[ "$BOOT" != "$MISC" ] || die "boot_b and misc resolved to the same device"
boot_bytes=$(pbytes "$BOOT") || die "cannot read the size of $BOOT"
misc_bytes=$(pbytes "$MISC") || die "cannot read the size of $MISC"
[ "$(wc -c < "$IMG")" -eq "$boot_bytes" ] ||
    die "$IMG is $(wc -c < "$IMG") bytes but boot_b is $boot_bytes bytes"
[ "$misc_bytes" -eq "$MISC_BYTES_EXPECTED" ] ||
    die "misc is $misc_bytes bytes, expected $MISC_BYTES_EXPECTED; refusing an unfamiliar layout"
say "boot_b=$BOOT ($boot_bytes B) misc=$MISC ($misc_bytes B)"
say "image  $img_sha"
say "bcb    $bcb_sha"

# --- live state and backup ---------------------------------------------------
mkdir -p "$BACKUP_DIR" || die "cannot create $BACKUP_DIR"
case "$(stat -f -c %T "$BACKUP_DIR" 2>/dev/null || echo unknown)" in
    tmpfs|ramfs) die "$BACKUP_DIR is a ramdisk; the misc backup must survive the reboot (set BACKUP_DIR)" ;;
esac
df_avail=$(df -k "$BACKUP_DIR" 2>/dev/null | awk 'NR==2{print $4}')
[ -n "$df_avail" ] && [ "$df_avail" -ge $((4 * 1024)) ] ||
    die "less than 4 MiB free in $BACKUP_DIR for the misc backup"

ts=$(date +%Y%m%d-%H%M%S)
log=$BACKUP_DIR/flash-$ts.log
before=$BACKUP_DIR/misc-before-$ts.bin
window=$BACKUP_DIR/misc-bc-before-$ts.bin
after=$BACKUP_DIR/misc-after-$ts.bin
chk=$BACKUP_DIR/.chk.$$

dd if="$MISC" of="$before" bs=64k || die "misc backup failed"
flush "$MISC"
[ "$(wc -c < "$before")" -eq "$misc_bytes" ] || die "misc backup is not $misc_bytes bytes"
before_sha=$(file_sha "$before")
dd if="$before" of="$window" bs=1 skip=2048 count=32 || die "cannot read the backup's control block"
[ "$(wc -c < "$window")" -eq 32 ] || die "short read of the backup's control block"
live_sha=$(file_sha "$window")
say "misc backup $before ($before_sha)"
say "live bc $live_sha"
case "$live_sha" in
    "$MISC_BC_A_SHA") say "live bc is the canonical slot-A record" ;;
    "$MISC_BC_B_SHA") say "live bc is already the trial-B record" ;;
    *) say "live bc is neither canonical record (structure only, checked below)" ;;
esac
check_bcb_struct "$window" "live misc control block" ||
    die "the live misc control block is damaged; restore misc from a backup before arming"
if [ -n "$LIVE_BCB_SHA256" ] && [ "$live_sha" != "$LIVE_BCB_SHA256" ]; then
    die "live misc control block is $live_sha, expected $LIVE_BCB_SHA256"
fi
{
    echo "time     $ts"
    echo "image    $IMG $img_sha"
    echo "bcb      $BCB $bcb_sha"
    echo "boot_b   $BOOT $boot_bytes B"
    echo "misc     $MISC $misc_bytes B"
    echo "misc-ok  $before_sha"
    echo "live-bc  $live_sha"
} >> "$log" 2>/dev/null || say "warning: cannot append to $log"

if [ -n "$DRY_RUN" ]; then
    say "DRY_RUN: would write $IMG to $BOOT, then 32 bytes to $MISC at offset 2048"
    say "DRY_RUN: nothing changed"
    exit 0
fi

# --- boot_b -----------------------------------------------------------------
dd if="$IMG" of="$BOOT" bs=1M || die "writing $BOOT failed"
flush "$BOOT"
got=$(file_sha "$BOOT")
[ "$got" = "$img_sha" ] || {
    say "boot_b readback is $got, expected $img_sha"
    die "boot_b write not verified; misc untouched, slot a still active"
}
say "boot_b written and verified"

# --- misc control block -----------------------------------------------------
restore_backup() {
    say "restoring misc from $before"
    dd if="$before" of="$MISC" bs=64k 2>/dev/null || { say "RESTORE FAILED: write $before back by hand"; return 1; }
    flush "$MISC"
    [ "$(file_sha "$MISC")" = "$before_sha" ] || { say "RESTORE VERIFY FAILED: write $before back by hand"; return 1; }
    say "misc restored and verified; slot b is not armed"
    return 0
}

# count=32 is the point of this write: it can never spill past the record.
dd if="$BCB" of="$MISC" bs=1 seek=2048 count=32 conv=notrunc || die "writing the misc control block failed"
flush "$MISC"

dd if="$MISC" of="$chk" bs=1 skip=2048 count=32 2>/dev/null || { rm -f "$chk"; restore_backup; die "cannot re-read the misc control block"; }
if ! cmp -s "$chk" "$BCB"; then
    rm -f "$chk"
    restore_backup
    die "misc control block readback does not match $BCB"
fi
rm -f "$chk"

dd if="$MISC" of="$after" bs=64k 2>/dev/null || { restore_backup; die "cannot re-read misc"; }
flush "$MISC"
# cmp -l lists 1-based offsets of every differing byte; nothing outside 2048..2080
# may differ, and at most those 32 bytes can.
cmp -l "$before" "$after" 2>/dev/null | awk '
    $1 < 2049 || $1 > 2080 { print "byte " $1 " changed outside the control block"; bad = 1; exit }
    { n++ }
    END { if (!bad && n > 32) { print n " bytes changed, at most 32 possible"; bad = 1 } exit bad }' || {
    rm -f "$after"
    restore_backup
    die "misc changed outside the 32-byte control block"
}
rm -f "$after"
{
    echo "armed    $bcb_sha"
    echo "boot_b   $img_sha"
} >> "$log" 2>/dev/null || true
say "misc armed with $bcb_sha"
say "verified: 32 bytes at 2048 match, everything else in misc unchanged"
say "next: reboot to boot slot b (this script does not reboot)"
