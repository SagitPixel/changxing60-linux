#!/bin/sh
set -eu
D=/tmp/codex-audio/fast-first
mkdir -p "$D"
M=/usr/bin/amixer
$M -c 0 scontents > "$D/mixer-before.txt"
setc() { "$M" -c 0 sset "$1" "$2"; }
setc 'S_FAST_P_CODEC SWITCH' on
setc VBC_MUX_DAC0_OUT_SEL DAC_OUT_FROM_IIS
setc 'AOL EAR Sel' AOL
setc 'AO Mixer AOL' on
setc 'AO Mixer AOR' on
setc 'DA AOR' on
setc 'Speaker Mute' off
setc 'Earpiece Function' off
setc 'EAR_AOL Mixer DACAOL' off
setc 'DSP VBC Profile Update' 1
setc 'DSP VBC Profile Select' 1078657024
setc 'Speaker Function' on
P=$(awk -F: '/FE_ST_FAST /{gsub(" ","",$1);split($1,a,"-");print a[2]+0;exit}' /proc/asound/pcm)
[ -n "$P" ]
S=/proc/asound/card0/pcm${P}p/sub0
printf 'FAST pcm=%s start=' "$P"
cat /proc/uptime
/usr/bin/aplay -D hw:0,$P /tone-30s.wav > "$D/aplay.txt" 2>&1 &
AP=$!
for n in $(seq 1 40); do
 printf 'sample=%s uptime=' "$n" >> "$D/samples.txt"
 cut -d' ' -f1 /proc/uptime >> "$D/samples.txt"
 cat "$S/status" >> "$D/samples.txt"
 if grep -q RUNNING "$S/status"; then
  cat "$S/hw_params" > "$D/hw_params.txt"
  cat "$S/sw_params" > "$D/sw_params.txt"
 fi
 sleep 0.15
done
set +e
wait "$AP"; rc=$?
set -e
echo "aplay_rc=$rc" | tee "$D/result.txt"
cat "$D/aplay.txt"
cat "$D/hw_params.txt" 2>/dev/null || true
awk '/sample=|state:|hw_ptr|appl_ptr/' "$D/samples.txt"
dmesg > "$D/dmesg.txt"
cat /sys/kernel/debug/sprd-dma-diag/tx_status > "$D/dma.txt"
cat "$D/dma.txt"
grep -E 'mcdt|MCDT|Chan[0-9]|slave_id|pcm Start|scene_fast|vbc-profile|AGCP not accessible|timeout' "$D/dmesg.txt" | tail -60
