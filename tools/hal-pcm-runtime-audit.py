#!/usr/bin/env python3
"""Read-only ELF32 ARM audit of the HAL's runtime PCM lookup.

Usage: python tools/hal-pcm-runtime-audit.py work/hal/whale.so
Requires capstone. Never connects to, writes to, or calls code on the phone.
Function symbol extents can include literal pools; those bytes are not instructions.
"""
import hashlib
from pathlib import Path
import struct
import sys

from capstone import Cs, CS_ARCH_ARM, CS_MODE_ARM, CS_MODE_THUMB


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    path = Path(sys.argv[1])
    data = path.read_bytes()
    if data[:6] != b"\x7fELF\x01\x01" or struct.unpack_from("<H", data, 18)[0] != 40:
        raise ValueError("Expected little-endian ELF32 ARM")
    shoff = struct.unpack_from("<I", data, 32)[0]
    entsize, count, names_index = struct.unpack_from("<HHH", data, 46)
    sections = [struct.unpack_from("<10I", data, shoff + i * entsize)
                for i in range(count)]
    names_section = sections[names_index]
    names = data[names_section[4]:names_section[4] + names_section[5]]

    def cstring(blob, offset):
        return blob[offset:].split(b"\0", 1)[0].decode("utf-8", "replace")

    named = {cstring(names, section[0]): section for section in sections}
    dynsym = named[".dynsym"]
    strings_section = sections[dynsym[6]]
    strings = data[strings_section[4]:strings_section[4] + strings_section[5]]
    symbols = []
    for offset in range(dynsym[4], dynsym[4] + dynsym[5], dynsym[9]):
        name, value, size, info, other, index = struct.unpack_from("<IIIBBH", data, offset)
        symbols.append((cstring(strings, name), value, size, info, index))
    by_name = {symbol[0]: symbol for symbol in symbols}

    # This binary's ARM PLT has a 32-byte header and 16-byte entries.
    # Guard the layout rather than silently applying it to another HAL.
    plt, rel = named[".plt"], named[".rel.plt"]
    relocation_count = rel[5] // rel[9]
    if plt[5] != 32 + 16 * relocation_count:
        raise ValueError("Unsupported PLT layout; inspect this HAL separately")
    callees = {}
    for i, offset in enumerate(range(rel[4], rel[4] + rel[5], rel[9])):
        _, info = struct.unpack_from("<II", data, offset)
        callees[plt[3] + 32 + 16 * i] = symbols[info >> 8][0]

    print("file:", path)
    print("sha256:", hashlib.sha256(data).hexdigest())
    print("Read-only disassembly; symbol tails may contain literal pools.")
    for name in ("audio_utils_get_pcm_device", "platform_set_pcm_id",
                 "platform_set_pcm_id_v2", "platform_get_pcm_id"):
        _, value, size, _, index = by_name[name]
        address = value & ~1
        section = sections[index]
        offset = section[4] + address - section[3]
        print("\n%s: VA=0x%x file=0x%x size=%d" % (name, address, offset, size))
        mode = CS_MODE_THUMB if value & 1 else CS_MODE_ARM
        for insn in Cs(CS_ARCH_ARM, mode).disasm(data[offset:offset + size], address):
            annotation = ""
            if insn.mnemonic in ("bl", "blx") and insn.op_str.startswith("#"):
                annotation = callees.get(int(insn.op_str[1:], 0), "")
            print("  %08x  %-8s %-30s %s" %
                  (insn.address, insn.mnemonic, insn.op_str, annotation))
    return 0


if __name__ == "__main__":
    sys.exit(main())
