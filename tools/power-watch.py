#!/usr/bin/env python3
"""Capture plug/unplug transitions without writing any power-supply property."""
import json
from pathlib import Path
import time


def read(path):
    try:
        return Path(path).read_text().strip()
    except OSError as err:
        return str(err)


with open('/tmp/power-watch.jsonl', 'w') as out:
    for _ in range(180):
        row = {'uptime': read('/proc/uptime').split()[0]}
        for supply, props in {
            'battery': ['status', 'online', 'current_now', 'voltage_now', 'temp_ambient', 'usb_type'],
            'usb': ['online'],
            'bq2560x_charger': ['online', 'usb_type'],
        }.items():
            row[supply] = {p: read('/sys/class/power_supply/' + supply + '/' + p) for p in props}
        out.write(json.dumps(row) + '\n')
        out.flush()
        time.sleep(1)
