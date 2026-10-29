#!/usr/bin/env python3
"""Validate the 32-byte bootloader_control record at offset 0x800 of `misc`.

Layout as observed in the three known-good records on the 7552N (Unisoc LK), all of
which carry a matching CRC, so this is the layout LK actually reads:

    0  char[4]   slot_suffix          "_a\\0\\0" or "_b\\0\\0"
    4  u32 le    magic                0x42414342 ("BCAB")
    8  u8        version              1
    9  u8        nb_slot              2
   10  u8        recovery_tries_remaining
   11  u8        merge_status
   12  struct    slot_info[4]        2 bytes per slot:
                                     bits 0-3 priority (15 = highest, 0 = unbootable)
                                     bits 4-6 tries_remaining
                                     bit  7   successful_boot
                                     + 1 reserved byte, must be 0
   20  u8[8]    reserved             must be 0
   28  u32 le   crc32_le             zlib crc32 of bytes 0..27

usage: bcb.py check FILE...
"""
import struct
import sys
import zlib

MAGIC = 0x42414342
META_OFF = 12
META_STRIDE = 2
RESERVED_OFF = 20
RESERVED_LEN = 8
CRC_OFF = 28


def decode_meta(byte):
    return byte & 0xF, (byte >> 4) & 0x7, (byte >> 7) & 0x1


def check(path):
    with open(path, 'rb') as f:
        d = f.read()
    problems = []
    if len(d) != 32:
        problems.append('size is %d, must be 32' % len(d))
        return problems, None

    suffix = d[0:4]
    magic, = struct.unpack_from('<I', d, 4)
    version, nb_slot, recovery_tries, merge_status = d[8], d[9], d[10], d[11]
    if suffix[0:1] != b'_' or suffix[1:2] not in (b'a', b'b') or suffix[2:4] != b'\0\0':
        problems.append('slot_suffix %r is not "_a\\0\\0" or "_b\\0\\0"' % suffix)
    if magic != MAGIC:
        problems.append('magic 0x%08x is not 0x%08x ("BCAB")' % (magic, MAGIC))
    if version != 1:
        problems.append('version %d is not 1' % version)
    if nb_slot not in (2, 3, 4):
        problems.append('nb_slot %d is out of range 2..4' % nb_slot)
    if merge_status not in (0, 1, 2, 3):
        problems.append('merge_status %d is out of range' % merge_status)
    if d[RESERVED_OFF:RESERVED_OFF + RESERVED_LEN] != b'\0' * RESERVED_LEN:
        problems.append('reserved bytes 20..27 are not zero')

    slots = []
    for i in range(4):
        off = META_OFF + i * META_STRIDE
        priority, tries, successful = decode_meta(d[off])
        if d[off + 1] != 0:
            problems.append('slot %d reserved byte %d is not zero' % (i, off + 1))
        if i < nb_slot:
            if priority == 0 and successful:
                problems.append('slot %d has priority 0 but successful_boot=1' % i)
            if priority > 15:
                problems.append('slot %d priority %d out of range' % (i, priority))
            if not 0 <= tries <= 7:
                problems.append('slot %d tries_remaining %d out of range' % (i, tries))
        slots.append((priority, tries, successful))

    crc, = struct.unpack_from('<I', d, CRC_OFF)
    calc = zlib.crc32(d[:CRC_OFF]) & 0xFFFFFFFF
    if crc != calc:
        problems.append('crc32_le 0x%08x does not match 0x%08x over bytes 0..27'
                        % (crc, calc))

    info = {
        'suffix': suffix[1:2].decode(),
        'version': version,
        'nb_slot': nb_slot,
        'recovery_tries_remaining': recovery_tries,
        'merge_status': merge_status,
        'slots': slots,
        'crc32': crc,
    }
    return problems, info


def main(argv):
    if len(argv) < 2 or argv[0] != 'check':
        sys.stderr.write(__doc__)
        return 2
    bad = 0
    for path in argv[1:]:
        try:
            problems, info = check(path)
        except OSError as e:
            print('%s: %s' % (path, e))
            bad += 1
            continue
        if problems:
            bad += 1
            print('%s: INVALID' % path)
            for p in problems:
                print('  - ' + p)
            continue
        print('%s: slot _%s version %d nb_slot %d recovery_tries %d merge %d' % (
            path, info['suffix'], info['version'], info['nb_slot'],
            info['recovery_tries_remaining'], info['merge_status']))
        for i in range(info['nb_slot']):
            priority, tries, successful = info['slots'][i]
            print('  slot %c: priority %2d tries_remaining %d successful_boot %d' % (
                ord('a') + i, priority, tries, successful))
        print('  crc32_le 0x%08x ok' % info['crc32'])
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
