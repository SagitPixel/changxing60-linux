#!/usr/bin/env python3
"""Bounded primary microphone capture, restoring all modified mixer controls."""
import argparse
import array
import json
import math
from pathlib import Path
import re
import subprocess
import time
import wave

MIXER = '/usr/bin/amixer'


def ctl(name, value=None):
    return subprocess.check_output([MIXER, '-c', '0',
        'cget' if value is None else 'cset', 'name=' + name] +
        ([] if value is None else [str(value)]), text=True, stderr=subprocess.STDOUT)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--seconds', type=int, default=5, choices=range(1, 31))
    ap.add_argument('--output', default='/tmp/7552n-microphone.wav')
    ap.add_argument('--pcm', type=int, choices=(0, 2), default=0)
    args = ap.parse_args()
    settings = [
        ('agdsp_access_en', 'on'),
        ('ag_iis1_ext_sel_v2', 'aud_4ad_iis0_ad0'),
        ('S_NORMAL_AP01_C_CODEC SWITCH' if args.pcm == 0 else 'S_CAPTURE_DSP_CODEC SWITCH', 'on'),
        ('VBC_MUX_ADC0', 'ADC_IN_IIS1_ADC'),
        ('VBC_MUX_ADC0_IIS_PORT_SEL', 'VBC_IIS_PORT_IIS1'),
        ('VBC_MUX_ADC0_SOURCE', 'ADC_SOURCE_IIS'),
        ('Digital ADC In Sel', 'ADC'),
        ('Mic Function', 'on'),
        ('ADC_1 Gain ADC_1 Capture Volume', '4'),
        ('ADC_1 Mixer MIC1PGA_1 Switch', 'on'),
        ('AUD ADC0L Switch', 'on'),
        ('AUD ADC0R Switch', 'on'),
        ('VBC ADC0 DG Set', '24,24'),
    ]
    saved = []
    pcm = 'hw:0,' + str(args.pcm)
    report = {'settings': settings, 'pcm': pcm, 'samples': []}
    player = None
    try:
        for name, value in settings:
            old = re.search(r'^\s*: values=(.+)$', ctl(name), re.M)
            if old is None:
                raise RuntimeError('Cannot save ' + name)
            saved.append((name, old[1]))
            ctl(name, value)
        print('CAPTURE START', flush=True)
        player = subprocess.Popen(['/usr/bin/arecord', '-D', pcm, '-t', 'wav',
            '-f', 'S16_LE', '-r', '48000', '-c', '2', '--period-size=480',
            '--buffer-size=1920', '-d', str(args.seconds), args.output],
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        deadline = time.monotonic() + args.seconds + 6
        while player.poll() is None and time.monotonic() < deadline:
            status = Path(f'/proc/asound/card0/pcm{args.pcm}c/sub0/status')
            report['samples'].append(status.read_text() if status.exists() else 'closed')
            time.sleep(.1)
        if player.poll() is None:
            player.kill()
            report['timeout'] = True
        output, _ = player.communicate(timeout=3)
        report.update(rc=player.returncode, arecord=output)
        if Path(args.output).exists():
            with wave.open(args.output) as wav:
                audio = array.array('h', wav.readframes(wav.getnframes()))
                report.update(frames=len(audio) // wav.getnchannels(), rate=wav.getframerate(),
                              channels=wav.getnchannels())
            report['signal'] = []
            for ch in range(report['channels']):
                values = audio[ch::report['channels']]
                mean = sum(values) / len(values) if values else 0
                rms = math.sqrt(sum((v - mean)**2 for v in values) / len(values)) if values else 0
                report['signal'].append({'channel': ch, 'peak': max(map(abs, values), default=0),
                    'mean': mean, 'ac_rms': rms, 'distinct': len(set(values))})
                blocks = []
                for start in range(0, len(values), report['rate']):
                    block = values[start:start + report['rate']]
                    avg = sum(block) / len(block)
                    blocks.append(round(math.sqrt(sum((v - avg)**2 for v in block) / len(block)), 2))
                report['signal'][-1]['one_second_ac_rms'] = blocks
    finally:
        if player is not None and player.poll() is None:
            player.kill()
            player.wait()
        report['restore_errors'] = []
        for name, value in reversed(saved):
            try:
                ctl(name, value)
            except Exception as err:
                report['restore_errors'].append(str(err))
        print(json.dumps(report, ensure_ascii=False, indent=2), flush=True)


if __name__ == '__main__':
    main()
