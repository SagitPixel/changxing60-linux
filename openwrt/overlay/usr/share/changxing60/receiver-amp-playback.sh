#!/bin/sh
# 7552N 6.18: drive the AW87xxx in its Receiver profile while the codec feeds it
# through the speaker (AO) path, with the codec's external ear switch on.
# Quiet on purpose: the receiver sits next to the ear.
set -eu
WAV=${1:?usage: receiver-amp-playback.sh FILE.wav [SECONDS]}
SECS=${2:-4}
CARD=${CARD:-0}
M=${AMIXER:-/usr/bin/amixer}
AMP=/sys/bus/i2c/devices/6-0058

setc() { "$M" -q -c "$CARD" sset "$1" "$2" 2>/dev/null || echo "skip control: $1" >&2; }
setn() { "$M" -q -c "$CARD" cset "$1" "$2" 2>/dev/null || echo "skip control: $1" >&2; }

"$M" -c "$CARD" sget agdsp_access_en 2>/dev/null | grep -q '\[on\]' || \
    "$M" -q -c "$CARD" sset agdsp_access_en on
setc ag_iis0_ext_sel_v2 aud_4ad_iis0_da0
setc 'S_FAST_P_CODEC SWITCH' on
setc VBC_MUX_DAC0_OUT_SEL DAC_OUT_FROM_IIS
setc VBC_IIS_TX0_LRMOD_SEL RIGHT_HIGH

# Codec AO path feeding the smart PA, external switch to the earpiece.
setc 'AOL EAR Sel' AOL
setc 'AO Mixer AOL' on
setc 'AO Mixer AOR' on
setc 'DA AOR' on
setc 'Speaker Function' on
setc 'Speaker Mute' off
setc 'Earpiece Function' on
setc 'Earpiece Mute' off
setc 'EAR_AOL Mixer DACAOL' off
setc 'Ext Ear Switch' on
setc 'AO Gain AO' 2

setn 'name=VBC DAC0 DG Set' 10,10
setc 'DSP VBC Profile Update' 1
setc 'DSP VBC Profile Select' 1078657024

printf 'Receiver\n' > "$AMP/profile"
printf '1\n' > "$AMP/hwen"

P=$(awk -F: '/FE_ST_FAST / {gsub(" ","",$1); split($1,a,"-"); print a[2]+0; exit}' /proc/asound/pcm)
[ -n "$P" ] || { echo 'FE_ST_FAST is missing' >&2; exit 1; }
echo "amp-receiver card=$CARD pcm=$P gain=2 dg=10"
/usr/bin/aplay -D "hw:$CARD,$P" -d "$SECS" "$WAV" || rc=$?
printf 'Off\n' > "$AMP/profile" || true
exit "${rc:-0}"
