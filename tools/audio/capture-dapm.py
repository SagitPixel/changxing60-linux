#!/usr/bin/env python3
"""Read-only, bounded DAPM/DPCM snapshots; never opens PCM or modem devices.

Run on the phone. Call numbers and contact names are deliberately excluded.
The in/out counters are endpoint reachability counts, not graph edge counts.
"""
import argparse
import json
from pathlib import Path
import time


def read(path):
    try:
        return Path(path).read_text()
    except OSError as error:
        return 'read error: %s' % error


def snapshot():
    root = Path('/sys/kernel/debug/asoc/sprdphone-sc2730')
    widgets = list(root.glob('dapm/*')) + list(root.glob('*/dapm/*'))
    state = read('/run/changxing60-voice/state')
    # This state file uses KEY=VALUE lines. Do not collect caller identity.
    call = {k: v for line in state.splitlines() if '=' in line
            for k, v in [line.split('=', 1)] if k in ('state', 'dir')}
    return {
        'uptime': read('/proc/uptime').split()[0],
        'call': call,
        'audio': read('/run/changxing60-voice-audio/state'),
        'widgets': {str(p.relative_to(root)): read(p)
                    for p in widgets if p.is_file()},
        'dpcm': {str(p.relative_to(root)): read(p)
                 for p in root.glob('FE_*/state')},
        'pcm': {str(p): read(p)
                for p in Path('/proc/asound/card0').glob('pcm*/sub*/status')},
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--seconds', type=float, default=0)
    parser.add_argument('--interval', type=float, default=3)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    if not 0 <= args.seconds <= 300 or not 1 <= args.interval <= 30:
        parser.error('seconds must be 0..300 and interval 1..30')
    deadline = time.monotonic() + args.seconds
    with open(args.output, 'x') as output:
        while True:
            output.write(json.dumps(snapshot()) + '\n')
            output.flush()
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                break
            time.sleep(min(args.interval, remaining))


if __name__ == '__main__':
    main()
