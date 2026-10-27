#!/usr/bin/env python3
"""Temporary 7552N receiver trial against the confirmed factory call snapshot.

Run on the phone with the existing voice hook installed. This does not replace
the hook or place/answer/hang up calls. Only the receiver route is supported.
Shares the hook's monitor lock/FIFO so its normal stop command stops this trial.
The expected hook hash prevents silently testing against a different baseline.
"""
import hashlib
from pathlib import Path
import runpy
import sys

HOOK = Path('/opt/changxing60/bin/changxing60-voice-audio')
EXPECTED = 'e89c8893ceacc357a26c558c09ddd6d710e6f4b05bff3d44b54091c926c66eec'
AMP = Path('/sys/bus/i2c/devices/6-0058/profile')


def install():
    if hashlib.sha256(HOOK.read_bytes()).hexdigest() != EXPECTED:
        raise RuntimeError('voice hook differs from the reviewed baseline')
    module = runpy.run_path(str(HOOK))
    base = module['VoiceAudio']
    g = base.start.__globals__
    g['ROUTES'].update({'VBC_MUX_ADC2': 'ADC_IN_IIS0_ADC',
                        'VBC DAC1 DG Set': '25,25'})
    g['MIC_CAPTURE'].update({
        'ADC_2 Gain ADC_2 Capture Volume': '7',
        'ADC_3 Gain ADC_3 Capture Volume': '7',
        'ADC_3 Mixer MIC3PGA_3 Switch': 'on',
        'Aux Mic2 Function': 'on',
        'ADD0 DATA SEL': 'ADD0_DATA_MIC13',
        'ADC LRCLK Select': 'invert', 'ADC1 LRCLK Select': 'invert',
    })
    # Speaker Function names the codec AO endpoint; it does not imply speakerphone.
    # The user confirmed calldump.txt was an ordinary receiver call.
    g['RECEIVER'] = {
        'VBC_SYSTEM_DEV_CHANGE': 'TYPE_RCV',
        'Earpiece Function': 'off', 'Speaker1 Function': 'off',
        'EAR_HPL Mixer DACHPL Switch': 'off', 'HPL EAR Sel': 'EAR',
        'EAR_AOL Mixer DACAOL Switch': 'off', 'DAHP OS D': '0',
        'VBC_MIXER1_DAC0': 'NOT_MIX', 'AOL EAR Sel': 'AOL',
        'AO Mixer AOL Switch': 'on', 'AO Mixer AOR Switch': 'on',
        'DA AOR Switch': 'on', 'Speaker Function': 'on',
    }
    g['CODEC_IIS'].update({
        'ag_iis0_ext_sel_v2': 'aud_4ad_iis0_da0',
        'ag_iis1_ext_sel_v2': 'aud_4ad_iis0_ad0',
        'DSP_DAC0_LR_EXCHANGE': 'disable',
        'VBC_IIS_MASTER_ENALBE': 'disable',
        'VBC_IIS_MST_SEL_0_TYPE': 'VBC_MASTER_EXTERNAL',
        'VBC_IIS_MST_SEL_1_TYPE': 'VBC_MASTER_EXTERNAL',
        'VBC_IIS_MST_SEL_2_TYPE': 'VBC_MASTER_EXTERNAL',
        'VBC_IIS_MST_SEL_3_TYPE': 'VBC_MASTER_EXTERNAL',
        'VBC DAC0 DSP MDG Set': '0,1024',
        'VBC DAC0 AUD MDG Set': '0,1024',
        'VBC DAC0 AUD23 MDG Set': '0,1024',
    })
    g['VOICE_CONTROLS'] = tuple(dict.fromkeys((
        *g['VOICE_CONTROLS'], *g['ROUTES'], *g['RECEIVER'],
        *g['MIC_CAPTURE'], *g['CODEC_IIS'])))

    class NativeReceiver(base):
        def __init__(self, config=None):
            super().__init__(config)
            self.amp_saved = None
            self.gains.update({'gain-dac-receiver': 0, 'gain-ao-receiver': 5,
                              'gain-ear-nb': 15, 'gain-ear-wb': 15,
                              'gain-ear-swb': 15, 'gain-ear-fb': 15})

        def profiles(self):
            if self.speaker or self.bluetooth:
                raise g['Failure']('native trial supports receiver only')
            super().profiles()
            # PCM startup's machine hook can overwrite the earlier amp choice.
            AMP.write_text('Receiver\n')

        def start(self):
            if self.handles:
                return
            modes = AMP.read_text().splitlines()
            selected = [line[1:].strip() for line in modes if line.startswith('>')]
            if len(selected) != 1 or 'Receiver' not in [x.lstrip('> ').strip() for x in modes]:
                raise g['Failure']('cannot snapshot amplifier profile')
            self.amp_saved = selected[0]
            try:
                super().start()
            except BaseException:
                self.stop()
                raise

        def stop(self):
            try:
                super().stop()
            finally:
                if self.amp_saved is not None:
                    saved = self.amp_saved
                    AMP.write_text(saved + '\n')
                    self.amp_saved = None

    g['VoiceAudio'] = NativeReceiver
    return g


if __name__ == '__main__':
    raise SystemExit(install()['main'](sys.argv[1:]))
