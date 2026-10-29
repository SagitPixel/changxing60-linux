#!/bin/sh
# One-shot trial boot of a Linux image on slot b, from rooted Android (adb + su).
# Writes ONLY boot_b and the 32-byte bootloader_control in misc; boot_a is never touched.
# usage: flash-trial.sh boot-linux-slotb.img   (expects .json and .misc-slot-b-trial.bin next to it)
set -eu
IMG=$1
BASE=${IMG%.img}
EXP=$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['sha256'])" "$BASE.json")
BC_B=$BASE.misc-slot-b-trial.bin
A_HEX=$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['misc_slot_a_hex'])" "$BASE.json")
su_do() { adb shell "su -c '$1'" | tr -d '\r'; }
# Read the 32-byte control block back into a device file first, so the size is checked
# instead of hoping the dd|od pipeline reported dd's status (it reports od's).
read_bc() {
    su_do 'dd if=/dev/block/by-name/misc of=/data/local/tmp/bc.live bs=1 skip=2048 count=32 2>/dev/null' >/dev/null
    [ "$(su_do 'wc -c < /data/local/tmp/bc.live' | tr -d ' ')" = 32 ] ||
        { echo "cannot read the 32-byte control block in misc" >&2; exit 1; }
    su_do 'od -An -tx1 -v /data/local/tmp/bc.live' | tr -d ' \n'
}

[ "$(shasum -a 256 "$IMG" | cut -d' ' -f1)" = "$EXP" ] || { echo "local image hash mismatch" >&2; exit 1; }
[ -f "$BC_B" ] || { echo "missing $BC_B" >&2; exit 1; }
python3 "$(dirname "$0")/../tools/bcb.py" check "$BC_B" >/dev/null ||
    { echo "$BC_B is not a valid bootloader_control record" >&2; exit 1; }
[ -n "$A_HEX" ] || { echo "$BASE.json has no misc_slot_a_hex" >&2; exit 1; }
[ "$(su_do 'getprop ro.boot.slot_suffix')" = "_a" ] || { echo "device is not running slot a" >&2; exit 1; }
live=$(read_bc)
[ "$live" = "$A_HEX" ] || { echo "misc bootloader_control is not the expected slot-a state: $live" >&2; exit 1; }

adb push "$IMG" /data/local/tmp/changxing60-boot.img
adb push "$BC_B" /data/local/tmp/changxing60-bc-b.bin
[ "$(su_do 'sha256sum /data/local/tmp/changxing60-boot.img' | cut -d' ' -f1)" = "$EXP" ] || { echo "pushed image hash mismatch" >&2; exit 1; }
[ "$(su_do 'sha256sum /data/local/tmp/changxing60-bc-b.bin' | cut -d' ' -f1)" = "$(shasum -a 256 "$BC_B" | cut -d' ' -f1)" ] ||
    { echo "pushed control block hash mismatch -- nothing written to misc" >&2; exit 1; }
su_do 'dd if=/data/local/tmp/changxing60-boot.img of=/dev/block/by-name/boot_b bs=4M && sync'
[ "$(su_do 'sha256sum /dev/block/by-name/boot_b' | cut -d' ' -f1)" = "$EXP" ] || { echo "boot_b verify failed; slot a is still active" >&2; exit 1; }
# count=32 caps the write at the record; the readback below is the real proof.
su_do 'dd if=/data/local/tmp/changxing60-bc-b.bin of=/dev/block/by-name/misc bs=1 seek=2048 count=32 conv=notrunc; sync' >/dev/null
new=$(read_bc)
B_HEX=$(od -An -tx1 -v "$BC_B" | tr -d ' \n')
if [ "$new" != "$B_HEX" ]; then
    echo "misc verify failed: $new != $B_HEX; restoring the slot-a record" >&2
    python3 -c 'import sys;sys.stdout.buffer.write(bytes.fromhex(sys.argv[1]))' "$A_HEX" > "$BASE.misc-slot-a-restore.bin"
    adb push "$BASE.misc-slot-a-restore.bin" /data/local/tmp/changxing60-bc-a.bin >/dev/null
    su_do 'dd if=/data/local/tmp/changxing60-bc-a.bin of=/dev/block/by-name/misc bs=1 seek=2048 count=32 conv=notrunc; sync' >/dev/null
    [ "$(read_bc)" = "$A_HEX" ] || { echo "RESTORE FAILED: misc control block is not the slot-a record; do not reboot" >&2; exit 1; }
    echo "slot-a record restored; slot b not armed" >&2
    exit 1
fi
echo "misc armed: $new"
echo "slot b armed (one-shot). Readback verified; reboot when ready: adb reboot"
