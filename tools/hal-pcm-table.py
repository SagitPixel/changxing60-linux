#!/usr/bin/env python3
"""Dump the PCM device table out of a Unisoc audio HAL.

  python tools/hal-pcm-table.py work/hal/whale.so

The table is an array of `struct { char name[100]; int device; }` (stride 0x68). We locate it by
looking for the run of "FE_ST_*" strings that sits at a constant 0x68 stride, then decode each
entry. See docs/HAL-REVERSE.md for why this matters: the kernel's own PCM numbering has to agree
with this table or every use case maps to the wrong FE.
"""
import re
import struct
import sys

STRIDE = 0x68
NAME_MAX = 100
DEV_OFF = 0x64


def find_table(d):
    """Return (offset, count) of the longest 0x68-strided run of FE_ST_* names."""
    hits = [m.start() for m in re.finditer(rb"FE_ST_[A-Z0-9_]+", d)]
    best, best_len = None, 0
    for start in hits:
        count, o = 0, start
        while o + STRIDE <= len(d) and d[o:o + 6] == b"FE_ST_":
            count += 1
            o += STRIDE
        if count > best_len:
            best, best_len = start, count
    return best, best_len


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    d = open(sys.argv[1], "rb").read()
    base, count = find_table(d)
    if not base:
        print("no FE_ST_* table found")
        return 1
    print("table at file offset %#x, %d entries\n" % (base, count))
    print("%6s  %-26s %s" % ("entry", "name", "device"))
    for i in range(count):
        e = d[base + i * STRIDE: base + (i + 1) * STRIDE]
        name = e[:NAME_MAX].split(b"\0")[0].decode("utf-8", "replace")
        dev, = struct.unpack_from("<i", e, DEV_OFF)
        print("%6d  %-26s %d" % (i, name, dev))
    return 0


if __name__ == "__main__":
    sys.exit(main())
