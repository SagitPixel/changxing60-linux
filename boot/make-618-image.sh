#!/bin/sh
# Rebuild the slot-b boot image with the 6.18 module set and the new load order.
#
# Replaces /init and /etc/module-order, and installs every module listed in
# boot/module-order-618.txt from work/mod618 (the module set built from the same
# kernel tree as the Image in this image). Modules whose name already exists in the
# base ramdisk are replaced; the rest are added. The 5.4 modules that nothing
# references any more are left in place -- /etc/module-order is the only list /init
# reads, so they are inert.
#
# usage: sh boot/make-618-image.sh [base.img] [out.img]
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
BASE=${1:-$ROOT/work/boot-618-slotb.img}
OUT=${2:-$ROOT/work/boot-618-slotb-modules.img}
MODS=$ROOT/work/mod618
ORDER=$HERE/module-order-618.txt

[ -f "$BASE" ] || { echo "base image not found: $BASE" >&2; exit 1; }
[ -d "$MODS" ] || { echo "module dir not found: $MODS" >&2; exit 1; }

# which names the base ramdisk already has
EXISTING=$(python3 "$HERE/repack-ramdisk.py" --base "$BASE" --show | awk '{print $4}')

set -- --base "$BASE" --out "$OUT" \
       --set "init=$HERE/init" \
       --set "etc/module-order=$ORDER"

missing=0
added=0
replaced=0
while read -r m; do
    [ -n "$m" ] || continue
    if [ ! -f "$MODS/$m" ]; then
        echo "MISSING module: $m" >&2
        missing=$((missing + 1))
        continue
    fi
    if printf '%s\n' "$EXISTING" | grep -qx "linux-modules/$m"; then
        set -- "$@" --set "linux-modules/$m=$MODS/$m"
        replaced=$((replaced + 1))
    else
        set -- "$@" --add "linux-modules/$m=$MODS/$m"
        added=$((added + 1))
    fi
done < "$ORDER"

[ "$missing" -eq 0 ] || { echo "$missing module(s) missing, aborting" >&2; exit 1; }

# The VBC driver loads its DSP audio profiles with request_firmware(), which looks in
# /lib/firmware. Without them the DSP answers every SIPC command but never runs an
# audio task, so they ship inside the ramdisk.
FW=$ROOT/work/firmware
for f in audio_structure cvs dsp_vbc; do
    [ -f "$FW/$f" ] || { echo "MISSING firmware: $f" >&2; exit 1; }
    if printf '%s\n' "$EXISTING" | grep -qx "lib/firmware/$f"; then
        set -- "$@" --set "lib/firmware/$f=$FW/$f"
    else
        set -- "$@" --add "lib/firmware/$f=$FW/$f"
    fi
done
echo "firmware: audio_structure cvs dsp_vbc"

# The 7552N analogue PA needs its board-specific ACF before its first probe.
# DSP profiles alone allow PCM progress but leave the speaker amplifier off.
AW_FW=${AW_FW:-$ROOT/work/audio/aw87xxx_acf.bin}
[ -f "$AW_FW" ] || { echo "MISSING PA firmware: $AW_FW" >&2; exit 1; }
if printf '%s\n' "$EXISTING" | grep -qx "lib/firmware/aw87xxx_acf.bin"; then
    set -- "$@" --set "lib/firmware/aw87xxx_acf.bin=$AW_FW"
else
    set -- "$@" --add "lib/firmware/aw87xxx_acf.bin=$AW_FW"
fi
if printf '%s\n' "$EXISTING" | grep -qx "usr/share/changxing60/fast-playback.sh"; then
    set -- "$@" --set "usr/share/changxing60/fast-playback.sh=$ROOT/tools/audio/fast-playback.sh"
else
    set -- "$@" --add "usr/share/changxing60/fast-playback.sh=$ROOT/tools/audio/fast-playback.sh"
fi

echo "modules: $replaced replaced, $added added"
python3 "$HERE/repack-ramdisk.py" "$@"
ls -l "$OUT"
