#!/usr/bin/env python3
"""Extract retained kernel errors and diagnostic candidates without clearing logs."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('directory', type=Path)
    folder = ap.parse_args().directory
    lines = (folder / 'dmesg.txt').read_text(errors='replace').splitlines()
    strict, candidates = [], []
    groups, severity = Counter(), Counter()
    pattern = re.compile(r'error|fail|timeout|not found|not ready|cannot|can not|invalid|unknown|warning|BUG:|Oops|panic', re.I)
    for line in lines:
        match = re.match(r'<([0-7])>\[\s*([\d.]+)\]\s*(.*)', line)
        if match is None:
            continue
        level, _, message = match.groups()
        severity[level] += 1
        if int(level) <= 3:
            strict.append(line)
        if int(level) <= 3 or pattern.search(message):
            candidates.append(line)
            key = re.sub(r'\b0x[0-9a-f]+\b|\b\d+\b', 'N', message)
            groups[key] += 1
    (folder / 'kernel-errors.txt').write_text('\n'.join(strict) + '\n')
    (folder / 'kernel-error-candidates.txt').write_text('\n'.join(candidates) + '\n')
    syslog = (folder / 'syslog.txt').read_text(errors='replace').splitlines()
    (folder / 'syslog-errors.txt').write_text('\n'.join(
        line for line in syslog if re.search(r'\.(err|crit|alert|emerg) ', line)) + '\n')
    result = {'kernel_lines': len(lines), 'kernel_severities': dict(severity),
              'error_level_lines': len(strict), 'candidates': len(candidates),
              'groups': [{'count': n, 'message': message} for message, n in groups.most_common()]}
    (folder / 'error-groups.json').write_text(json.dumps(result, indent=2, ensure_ascii=False))
    print(json.dumps({k: v for k, v in result.items() if k != 'groups'}))


if __name__ == '__main__':
    main()
