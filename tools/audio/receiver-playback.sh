#!/bin/sh
# 7552N 6.18: play a file through the earpiece (codec EAR path, AW87xxx off).
# Usage: sh receiver-playback.sh FILE.wav [SECONDS]
set -eu
WAV=${1:?usage: receiver-playback.sh FILE.wav [SECONDS]}
SECS=${2:-4}
CARD=${CARD:-0}
M=${AMIXER:-/usr/bin/amixer}
AMP=/sys/bus/i2c/devices/6-0058/profile

setc() {
    "$M" -q -c "$CARD" sset "$1" "$2" 2>/dev/null || echo "skip control: $1" >&2
}
setn() {
    "$M" -q -c "$CARD" cset "$1" "$2" 2>/dev/null || echo "skip control: $1" >&2
}

"$M" -c "$CARD" sget agdsp_access_en 2>/dev/null | grep -q '\[on\]' || \
    "$M" -q -c "$CARD" sset agdsp_access_en on
setc ag_iis0_ext_sel_v2 aud_4ad_iis0_da0
setc 'S_FAST_P_CODEC SWITCH' on
setc VBC_MUX_DAC0_OUT_SEL DAC_OUT_FROM_IIS
setc VBC_IIS_TX0_LRMOD_SEL RIGHT_HIGH

# Codec EAR path: DAC AOL -> EAR mixer -> EAR pin. Speaker off.
setc 'AOL EAR Sel' EAR
setc 'EAR_AOL Mixer DACAOL' on
setc 'Earpiece Function' on
setc 'Earpiece Mute' off
setc 'EAR Gain EAR' 6
setc 'Speaker Function' off
setc 'Speaker Mute' on
setc 'Speaker1 Function' off
setc 'Speaker2 Mute' on
setc 'AO Mixer AOL' off
setc 'AO Mixer AOR' off

setn 'name=VBC DAC0 DG Set' 12,12
setc 'DSP VBC Profile Update' 1
setc 'DSP VBC Profile Select' 1078657024

# The earpiece is on the codec, not the smart PA.
[ -f "$AMP" ] && printf 'Off\n' > "$AMP" || true

P=$(awk -F: '/FE_ST_FAST / {gsub(" ","",$1); split($1,a,"-"); print a[2]+0; exit}' /proc/asound/pcm)
[ -n "$P" ] || { echo 'FE_ST_FAST is missing' >&2; exit 1; }
echo "receiver card=$CARD pcm=$P gain=6 dg=12"
exec /usr/bin/aplay -D "hw:$CARD,$P" -d "$SECS" "$WAV"
