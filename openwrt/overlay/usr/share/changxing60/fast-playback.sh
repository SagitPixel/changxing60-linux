#!/bin/sh
# 7552N 6.18 media playback through the stock FAST / internal IIS0 / AO route.
# Usage: sh fast-playback.sh FILE.wav [SECONDS]
# The AGDSP reference must precede IIS routing and cover the entire stream.
set -eu
WAV=${1:?usage: fast-playback.sh FILE.wav [SECONDS]}
CARD=${CARD:-0}
M=${AMIXER:-/usr/bin/amixer}
P=${APLAY:-/usr/bin/aplay}
AMP=/sys/bus/i2c/devices/6-0058/profile
LOCK=/run/changxing60-fast-playback.lock
mkdir "$LOCK" 2>/dev/null || { echo 'another FAST test owns the audio route' >&2; exit 1; }
owned_access=0
old_amp=
player=
cleanup() {
    result=$?
    trap - EXIT INT TERM HUP
    if [ -n "$player" ]; then kill "$player" 2>/dev/null || :; wait "$player" 2>/dev/null || :; fi
    if [ -n "$old_amp" ]; then printf '%s\n' "$old_amp" > "$AMP" || :; fi
    if [ "$owned_access" = 1 ]; then "$M" -q -c "$CARD" sset agdsp_access_en off || :; fi
    rmdir "$LOCK"
    exit "$result"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP
if ! "$M" -c "$CARD" sget agdsp_access_en | grep -q '\[on\]'; then
    "$M" -q -c "$CARD" sset agdsp_access_en on
    owned_access=1
fi
"$M" -c "$CARD" sget agdsp_access_en | grep -q '\[on\]'
"$M" -q -c "$CARD" sset ag_iis0_ext_sel_v2 aud_4ad_iis0_da0
"$M" -q -c "$CARD" sset 'S_FAST_P_CODEC SWITCH' on
"$M" -q -c "$CARD" sset VBC_MUX_DAC0_OUT_SEL DAC_OUT_FROM_IIS
"$M" -q -c "$CARD" sset VBC_IIS_TX0_LRMOD_SEL RIGHT_HIGH
"$M" -q -c "$CARD" sset 'AOL EAR Sel' AOL
"$M" -q -c "$CARD" sset 'AO Mixer AOL' on
"$M" -q -c "$CARD" sset 'AO Mixer AOR' on
"$M" -q -c "$CARD" sset 'DA AOR' on
"$M" -q -c "$CARD" sset 'Speaker Mute' off
"$M" -q -c "$CARD" sset 'Earpiece Function' off
"$M" -q -c "$CARD" sset 'EAR_AOL Mixer DACAOL' off
"$M" -q -c "$CARD" cset 'name=VBC DAC0 DSP MDG Set' 0,1
"$M" -q -c "$CARD" cset 'name=VBC DAC0 AUD MDG Set' 0,1
"$M" -q -c "$CARD" cset 'name=VBC DAC0 DG Set' 33,33
"$M" -q -c "$CARD" sset 'AO Gain AO' 3
"$M" -q -c "$CARD" sset 'DSP VBC Profile Update' 1
"$M" -q -c "$CARD" sset 'DSP VBC Profile Select' 1078657024
"$M" -q -c "$CARD" sset 'Speaker Function' on
if [ -f "$AMP" ]; then
    grep -q 'Music' "$AMP" || { echo 'AW87xxx firmware is not loaded' >&2; exit 1; }
    old_amp=$(sed -n 's/^>//p' "$AMP")
    echo Music > "$AMP"
fi
PCM=$(awk -F: '/FE_ST_FAST / {gsub(" ","",$1); split($1,a,"-"); print a[2]+0; exit}' /proc/asound/pcm)
[ -n "$PCM" ] || { echo 'FE_ST_FAST is missing' >&2; exit 1; }
echo "FAST card=$CARD pcm=$PCM profile=0x404b0000 iis0=aud_4ad_iis0_da0"
if [ -n "${2:-}" ]; then
    "$P" -D "hw:$CARD,$PCM" -d "$2" "$WAV" &
else
    "$P" -D "hw:$CARD,$PCM" "$WAV" &
fi
player=$!
set +e
wait "$player"
result=$?
set -e
player=
exit "$result"
