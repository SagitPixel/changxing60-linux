#!/bin/sh
set -eu
D=/tmp/codex-audio/ablation
mkdir -p "$D"
M=/usr/bin/amixer
probe() {
 tag=$1
 /usr/bin/aplay -D hw:0,3 -d 3 /tone-30s.wav > "$D/$tag.aplay" 2>&1 &
 ap=$!
 for n in $(seq 1 24); do
  printf '%s ' "$(cut -d' ' -f1 /proc/uptime)" >> "$D/$tag.samples"
  grep -E 'state:|hw_ptr|appl_ptr' /proc/asound/card0/pcm3p/sub0/status | tr '\n' '|' >> "$D/$tag.samples" || true
  echo >> "$D/$tag.samples"
  sleep 0.2
 done
 set +e; wait "$ap"; rc=$?; set -e
 echo "$tag rc=$rc"
 awk '/hw_ptr/{print}' "$D/$tag.samples" | head -2
 awk '/hw_ptr/{print}' "$D/$tag.samples" | tail -2
 cat "$D/$tag.aplay"
}
$M -q -c 0 sset VBC_IIS_MST_WIDTH_SET MST_WD_24BIT
probe master24
$M -q -c 0 sset VBC_IIS_MST_WIDTH_SET MST_WD_16BIT
probe master16
$M -q -c 0 cset 'name=VBC DAC0 DG Set' 0,0
probe dg0
$M -q -c 0 cset 'name=VBC DAC0 DG Set' 33,33
$M -q -c 0 sset agdsp_access_en off
probe access_off
$M -q -c 0 sset agdsp_access_en on
probe access_on
