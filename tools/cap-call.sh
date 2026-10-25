#!/system/bin/sh
# 等 Android 进入通话，抓一份完整快照。用法：su -c 'sh /data/local/tmp/cap.sh'
D=/sys/kernel/debug/asoc
OUT=/sdcard/calldump.txt

: > $OUT
echo "card=$(ls $D | head -1)" >> $OUT

# 等最多 5 分钟，直到有 PCM 在 RUNNING
i=0
run=""
while [ $i -lt 100 ]; do
    for f in /proc/asound/card0/pcm*p/sub0/status; do
        [ -e "$f" ] || continue
        head -1 "$f" 2>/dev/null | grep -q RUNNING && run="$run $f"
    done
    [ -n "$run" ] && break
    i=$((i+1))
    sleep 3
done
echo "running:$run" >> $OUT

echo "--- APB_EB0 及附近寄存器 (0x56390000) ---" >> $OUT
head -4 /sys/kernel/debug/regmap/dummy-syscon@56390000/registers 2>/dev/null >> $OUT

# 关键控件：逐个组件、逐字匹配（控件名带空格，不能用 for 展开）
echo "--- 关键 DAPM 控件 ---" >> $OUT
for comp in "$D"/*; do
    [ -d "$comp/dapm" ] || continue
    name=$(basename "$comp")
    for w in Digital\ Power Analog\ Power DAC CLK_DAC CLK_ADC \
             Normal-Playback Voice-Playback Voice-Capture ADC; do
        f="$comp/dapm/$w"
        [ -e "$f" ] && echo "$name/$w :: $(head -1 "$f")" >> $OUT
    done
done

echo "--- tinymix ---" >> $OUT
tinymix >> $OUT 2>/dev/null

echo "=== DONE ===" >> $OUT
