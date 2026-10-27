#!/usr/bin/env python3
"""Swap the kernel payload of an Android boot image (header v4) without rebuilding
the ramdisk. Keeps the existing LZ4 ramdisk, AVB blob bytes (hash is stale but the
device bypasses verification), and updates the AVB footer's original_size so the
footer still parses.

usage: swap-kernel.py --src boot.img --kernel Image.lk --out boot-new.img
"""
import argparse
import struct
from pathlib import Path

PAGE = 4096
MAGIC = b"ANDROID!"


def round_up(n, k):
    return (n + k - 1) // k * k


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True, type=Path)
    ap.add_argument("--kernel", required=True, type=Path)
    ap.add_argument("--out", required=True, type=Path)
    a = ap.parse_args()

    base = a.src.read_bytes()
    assert base[:8] == MAGIC, "not an Android boot image"
    hv = struct.unpack_from("<I", base, 40)[0]
    assert hv == 4, f"only v4 supported, got hdr_ver={hv}"

    ksz = struct.unpack_from("<I", base, 8)[0]
    rdsz = struct.unpack_from("<I", base, 12)[0]
    print(f"src: kernel={ksz} ramdisk={rdsz} page={PAGE}")

    k_off = PAGE
    rd_off = k_off + round_up(ksz, PAGE)
    body_end = rd_off + round_up(rdsz, PAGE)  # this is the old original_size

    # AVB footer is the last 64 bytes
    footer = bytearray(base[-64:])
    # footer[12:20] = original_size (BE u64), footer[20:28] = original_size again, footer[28:36] = avb_size
    avb_off, avb_size = struct.unpack_from(">QQ", base, len(base) - 44)
    print(f"  avb: off={avb_off} size={avb_size}")
    avb_blob = base[avb_off:avb_off + avb_size]
    assert len(avb_blob) == avb_size, "avb blob mismatch"

    ramdisk = base[rd_off:rd_off + rdsz]

    kern = a.kernel.read_bytes()
    hdr = bytearray(base[:PAGE])
    struct.pack_into("<I", hdr, 8, len(kern))  # new kernel_size

    body = bytes(hdr) + kern + b"\0" * ((-len(kern)) % PAGE) + ramdisk
    body += b"\0" * ((-len(body)) % PAGE)
    new_original_size = len(body)
    print(f"  new original_size={new_original_size} (was {body_end})")

    body += avb_blob
    # pad to original image size minus the 64-byte footer
    body += b"\0" * (len(base) - 64 - len(body))
    struct.pack_into(">QQQ", footer, 12, new_original_size, new_original_size, avb_size)

    image = body + bytes(footer)
    assert len(image) == len(base), f"size mismatch {len(image)} != {len(base)}"
    a.out.write_bytes(image)
    print(f"out: {a.out} ({len(image)} bytes), kernel {len(kern)}")


if __name__ == "__main__":
    main()
