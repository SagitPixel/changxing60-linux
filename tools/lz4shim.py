#!/usr/bin/env python3
"""Small LZ4 legacy-frame shim for Android boot ramdisks.

The Windows host has the Python lz4 module but not the `lz4` CLI used by
repack-ramdisk.py. Android's boot ramdisk uses the legacy 8 MiB-block format
(`lz4 -l`), not the newer LZ4 frame format.
"""
import sys
import struct

import lz4.block

MAGIC = bytes.fromhex("02214c18")
BLOCK = 8 * 1024 * 1024
RAW_FLAG = 0x80000000


def decompress(data):
    if not data.startswith(MAGIC):
        raise SystemExit("not an LZ4 legacy frame")
    pos = len(MAGIC)
    out = bytearray()
    while pos + 4 <= len(data):
        word = struct.unpack_from("<I", data, pos)[0]
        pos += 4
        if word == 0:
            break
        raw = bool(word & RAW_FLAG)
        size = word & 0x7fffffff
        block = data[pos:pos + size]
        if len(block) != size:
            raise SystemExit("truncated LZ4 legacy block")
        pos += size
        out.extend(block if raw else lz4.block.decompress(block, uncompressed_size=BLOCK))
    if pos != len(data):
        raise SystemExit("trailing bytes in LZ4 legacy frame")
    return bytes(out)


def compress(data):
    out = bytearray(MAGIC)
    for pos in range(0, len(data), BLOCK):
        block = data[pos:pos + BLOCK]
        packed = lz4.block.compress(
            block, mode="high_compression", compression=12, store_size=False
        )
        if len(packed) >= len(block):
            out.extend(struct.pack("<I", len(block) | RAW_FLAG))
            out.extend(block)
        else:
            out.extend(struct.pack("<I", len(packed)))
            out.extend(packed)
    return bytes(out)


def main():
    args = sys.argv[1:]
    if "-d" in args:
        sys.stdout.buffer.write(decompress(sys.stdin.buffer.read()))
        return
    if "-l" in args or not args:
        sys.stdout.buffer.write(compress(sys.stdin.buffer.read()))
        return
    raise SystemExit("usage: lz4shim.py [-d] [-l] -c")


if __name__ == "__main__":
    main()
