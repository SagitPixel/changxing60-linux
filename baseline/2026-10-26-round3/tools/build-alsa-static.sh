#!/bin/sh
# Build static aarch64 alsa-lib + amixer/aplay/arecord for the minimal 6.18 ramdisk.
#
# This is deliberately NOT tools/build-alsa.sh: that one installs OpenWrt packages into a
# full rootfs. The ramdisk has no package manager, no shared libs and no /usr, so we need
# self-contained executables plus the alsa.conf tree.
#
# The prefix is /usr because alsa-lib bakes its config dir into the binaries: whatever
# --prefix says is the /share/alsa the tools look for at run time. Installing into
# DESTDIR keeps that path while writing into a scratch tree here.
#
# Run inside changxing60-kbuild-618:
#   sh tools/build-alsa-static.sh [outdir]
#
# Output (default /repo/work/alsa-static):
#   amixer aplay arecord      static aarch64 ELF
#   share/alsa/...            goes to /usr/share/alsa in the ramdisk
set -eu

OUT=${1:-/repo/work/alsa-static}
LIBV=1.2.12
UTLV=1.2.12
WORK=/tmp/alsa-build
DEST=$WORK/dest

mkdir -p "$OUT"
rm -rf "$WORK" "$OUT/share"
mkdir -p "$WORK"
cd "$WORK"

echo "== fetch =="
wget -q "https://www.alsa-project.org/files/pub/lib/alsa-lib-$LIBV.tar.bz2" -O lib.tar.bz2
wget -q "https://www.alsa-project.org/files/pub/utils/alsa-utils-$UTLV.tar.bz2" -O utils.tar.bz2
tar xf lib.tar.bz2
tar xf utils.tar.bz2

echo "== alsa-lib (static, prefix=/usr) =="
cd "alsa-lib-$LIBV"
# -fPIC on purpose: alsa-utils' libtool link wants PIC objects even when it ends up
# pulling the .a. The final binary is relinked with -static anyway.
CFLAGS="-O2 -fPIC" \
./configure --host=aarch64-linux-gnu --prefix=/usr \
    --disable-shared --enable-static --disable-python \
    --without-debug --disable-docs > "$WORK/lib-conf.log" 2>&1 || {
    tail -25 "$WORK/lib-conf.log"; exit 1; }
make -j"$(nproc)" > "$WORK/lib-make.log" 2>&1 || { tail -25 "$WORK/lib-make.log"; exit 1; }
make install DESTDIR="$DEST" > "$WORK/lib-inst.log" 2>&1 || { tail -20 "$WORK/lib-inst.log"; exit 1; }
cd "$WORK"

echo "== alsa-utils (objects only, relinked below) =="
cd "alsa-utils-$UTLV"
CPPFLAGS="-I$DEST/usr/include" LDFLAGS="-L$DEST/usr/lib" \
./configure --host=aarch64-linux-gnu --prefix=/usr \
    --disable-shared --enable-static --disable-nls \
    --disable-alsamixer --disable-alsaconf --disable-alsatest \
    --disable-alsaloop --disable-bat --disable-rst2man \
    > "$WORK/utils-conf.log" 2>&1 || { tail -30 "$WORK/utils-conf.log"; exit 1; }

for d in amixer aplay; do
    make -C "$d" > "$WORK/utils-$d.log" 2>&1 || { tail -25 "$WORK/utils-$d.log"; exit 1; }
done
cd "$WORK"

echo "== relink static =="
# alsa-utils' link step goes through libtool, which drops -static, so relink from the
# objects; libasound was built --disable-shared, leaving only glibc to pin.
for d in amixer aplay; do
    ( cd "alsa-utils-$UTLV/$d" && \
      aarch64-linux-gnu-gcc -static -no-pie -o "$OUT/$d" *.o \
          -L"$DEST/usr/lib" -lasound -lm -ldl -lpthread ) \
      || { echo "relink $d failed"; exit 1; }
done
# arecord is the same binary, dispatched on argv[0]
cp "$OUT/aplay" "$OUT/arecord"
chmod 755 "$OUT"/amixer "$OUT"/aplay "$OUT"/arecord

mkdir -p "$OUT/share"
cp -r "$DEST/usr/share/alsa" "$OUT/share/"

for f in amixer aplay arecord; do
    printf '%-8s %s bytes  ' "$f" "$(stat -c%s "$OUT/$f")"
    file -b "$OUT/$f" | grep -oE 'ARM aarch64|statically linked'
done
du -sh "$OUT/share" | awk '{print "alsa config:", $1}'
