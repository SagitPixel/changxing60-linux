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
$M -q -c 0 sset ag_iis0_ext_sel_v2 pad_top
probe pad_top
$M -q -c 0 sset ag_iis0_ext_sel_v2 aud_4ad_iis0_da0
probe internal_iis
$M -q -c 0 sset VBC_IIS_TX0_LRMOD_SEL LEFT_HIGH
$M -q -c 0 sset VBC_IIS_TX1_WD_SEL WD_16BIT
$M -q -c 0 sset VBC_MUX_DAC1_IIS_PORT_SEL VBC_IIS_PORT_IIS1
$M -q -c 0 sset VBC_MUX_IIS3_PORT_DO_SEL IIS_DO_VAL_DAC0
$M -q -c 0 sset VBC_IIS_MST_WIDTH_SET MST_WD_24BIT
$M -q -c 0 cset 'name=VBC DAC0 DSP MDG Set' 0,0
$M -q -c 0 cset 'name=VBC DAC1 DSP MDG Set' 0,0
$M -q -c 0 cset 'name=VBC DAC0 AUD MDG Set' 0,0
$M -q -c 0 cset 'name=VBC DAC0 AUD23 MDG Set' 0,0
$M -q -c 0 cset 'name=VBC DAC0 DG Set' 0,0
probe default_dsp_parameters
