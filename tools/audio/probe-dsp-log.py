#!/usr/bin/env python3
"""Bounded Unisoc DSP log probe. Uses published ioctl ABI; no firmware writes.

LOG_ENABLE is scalar arg in audio_dsp_dump.c despite its _IOW encoding.
Does not enable DSP assertions, change buffer allocations, or touch PCM routes.
Only use with the matching driver and no other DSP-log consumer.
"""
import argparse
import collections
import fcntl
import hashlib
import json
import os
from pathlib import Path
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--seconds', type=float, default=5)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    if not 0 < args.seconds <= 30:
        parser.error('seconds must be in (0, 30]')
    path = '/dev/audio_dsp_log'
    result = {'device': path, 'seconds': args.seconds, 'ioctl': hex(0x40045800),
              'log_destination': 2}  # AUDIO_LOG_BY_ARMCOM; 1 routes to UART.
    fd = os.open(path, os.O_RDONLY | os.O_NONBLOCK)
    errors = collections.Counter()
    data = bytearray()
    zero_reads = 0
    enabled = False
    started = time.monotonic()
    try:
        result['enable_return'] = fcntl.ioctl(fd, 0x40045800, 2)
        enabled = True
        end = time.monotonic() + args.seconds
        while time.monotonic() < end and len(data) < 4 * 1024 * 1024:
            try:
                chunk = os.read(fd, 8192)
                data.extend(chunk)
                zero_reads += not bool(chunk)
            except OSError as exc:
                errors[str(exc.errno)] += 1
            time.sleep(0.2)
    except OSError as exc:
        result['failure'] = {'errno': exc.errno, 'message': str(exc)}
    finally:
        if enabled:
            try:
                result['disable_return'] = fcntl.ioctl(fd, 0x40045800, 0)
            except OSError as exc:
                result['disable_error'] = str(exc)
        os.close(fd)
    Path(args.output).write_bytes(data)
    result.update(elapsed=round(time.monotonic() - started, 3),
                  bytes=len(data), nonzero_bytes=sum(x != 0 for x in data),
                  zero_reads=zero_reads, read_errors=dict(errors),
                  sha256=hashlib.sha256(data).hexdigest())
    print(json.dumps(result, ensure_ascii=False, indent=2), flush=True)


if __name__ == '__main__':
    main()
