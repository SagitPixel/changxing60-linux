#!/usr/bin/env python3
"""Compare an Android tinymix snapshot with voice-audio dump (read-only).

Compare by control name, never numid. BYTE values are excluded because the raw
voice-audio dump uses integer slots and does not decode ALSA's byte union.
"""
import argparse
import json
from pathlib import Path
import re


def normalize(value):
    if value is None:
        return None
    return ','.join(value.strip().lower().replace(',', ' ').split())


def android_snapshot(text):
    # Some vendor BYTE getters omit a newline (aw_algo_auth in calldump.txt).
    # Find each typed record rather than assuming one control per line.
    pattern = re.compile(r'(\d+)\t(BOOL|INT|ENUM|BYTE|INT64)\t(\d+)\t')
    matches = list(pattern.finditer(text))
    records = {}
    for i, match in enumerate(matches):
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        payload = text[match.end():end].splitlines()[0].strip()
        parts = re.split(r'\s{2,}', payload, maxsplit=1)
        name = parts[0]
        if name in records:
            raise ValueError('duplicate Android control: ' + name)
        records[name] = {'type': match[2], 'value': parts[1] if len(parts) == 2 else None}
    count = re.search(r'Number of controls:\s*(\d+)', text)
    if count and len(records) != int(count[1]):
        raise ValueError('parsed %d controls, expected %s' % (len(records), count[1]))
    return records


def linux_snapshot(text):
    records = {}
    for line in text.splitlines():
        if '\t' not in line:
            continue
        name, value = line.split('\t', 1)
        if name in records:
            raise ValueError('duplicate Linux control: ' + name)
        records[name] = value
    if not records:
        raise ValueError('no Linux name<TAB>value records')
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--android', required=True)
    parser.add_argument('--linux', required=True)
    parser.add_argument('--output')
    args = parser.parse_args()
    android = android_snapshot(Path(args.android).read_text())
    linux = linux_snapshot(Path(args.linux).read_text())
    shared = android.keys() & linux.keys()
    excluded = sorted(n for n in shared if android[n]['type'] == 'BYTE'
                      or android[n]['value'] is None)
    differences = {n: {'android': android[n]['value'], 'linux': linux[n]}
                   for n in sorted(shared - set(excluded))
                   if normalize(android[n]['value']) != normalize(linux[n])}
    result = {'android_controls': len(android), 'linux_controls': len(linux),
              'missing_on_linux': sorted(android.keys() - linux.keys()),
              'linux_only': sorted(linux.keys() - android.keys()),
              'excluded_values': excluded, 'different_values': differences}
    output = json.dumps(result, ensure_ascii=False, indent=2) + '\n'
    if args.output:
        Path(args.output).write_text(output)
    print(output, end='')


if __name__ == '__main__':
    main()
