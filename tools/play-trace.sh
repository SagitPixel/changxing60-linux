#!/bin/sh
# One-shot playback trace: start aplay, then sample the PCM and DAPM state while it is
# still running, so we see whether the stream ever reaches RUNNING and whether the
# pointers move. Everything lands in /tmp/play-trace.txt.
D=/proc/asound/card0/pcm0p/sub0
C=/sys/kernel/debug/asoc/sprdphone-sc2730
OUT=/tmp/play-trace.txt
: > "$OUT"

echo "=== aplay start: $(date) ===" >> "$OUT"
echo "--- crossbar ---" >> "$OUT"
/tmp/alsa/amixer -c 0 sget 'S_NORMAL_AP01_P_CODEC SWITCH' 2>&1 | tail -1 >> "$OUT"

/tmp/alsa/aplay -D hw:0,0 /tmp/t.wav > /tmp/aplay.out 2>&1 &
AP=$!
START=$(date +%s)

i=0
while [ $i -lt 24 ]; do
    i=$((i + 1))
    echo "" >> "$OUT"
    echo "--- sample $i  t=$(( $(date +%s) - START ))s  pid_alive=$(kill -0 $AP 2>/dev/null && echo Y || echo N) ---" >> "$OUT"
    echo "[status]" >> "$OUT"
    head -12 "$D/status" 2>/dev/null >> "$OUT"
    echo "[dapm]" >> "$OUT"
    for w in S_NORMAL_AP01_P_CODEC FE_IF_NORMAL_AP01_P BE_IF_NORMAL_AP01_CODEC_P; do
        head -1 "$C/sprd-routing-pcm/dapm/$w" 2>/dev/null >> "$OUT"
    done
    for w in "Normal-Playback" DAC "Digital Power"; do
        head -1 "$C/64400000.spi:pmic@0:audio-codec@1000/dapm/$w" 2>/dev/null >> "$OUT"
    done
    sleep 0.4
done

wait $AP
RC=$?
echo "" >> "$OUT"
echo "=== aplay exit rc=$RC after $(( $(date +%s) - START ))s ===" >> "$OUT"
echo "[aplay output]" >> "$OUT"
cat /tmp/aplay.out >> "$OUT"

echo "" >> "$OUT"
echo "[hw_params]" >> "$OUT"
cat "$D/hw_params" 2>/dev/null >> "$OUT"
echo "[sw_params]" >> "$OUT"
cat "$D/sw_params" 2>/dev/null >> "$OUT"
echo "[dmesg tail]" >> "$OUT"
dmesg | tail -40 >> "$OUT"
echo "=== done ===" >> "$OUT"
