#!/bin/sh
set -eu
mkdir -p /tmp/codex-audio
uname -a
cat /proc/uptime
cat /proc/asound/cards
cat /proc/asound/pcm
cat /proc/modules
printf '\nMCDT DT\n'
N=/sys/firmware/devicetree/base/soc/agcp/mcdt@56500000
for f in compatible reg sprd,ap-addr-offset sprd,syscon-agcp-ahb; do
 echo "$f"; od -An -tx1 "$N/$f"
done
printf '\nPCM DT\n'
readlink -f /sys/bus/platform/devices/sprd-pcm-audio/of_node
for f in dma-names dmas; do
 echo "$f"; od -An -tx1 "/sys/bus/platform/devices/sprd-pcm-audio/of_node/$f"
done
printf '\nDMA mapping\n'
for d in /sys/class/dma/*; do readlink -f "$d"; done
printf '\nDiagnostic state\n'
cat /sys/module/sprd_dmaengine_pcm/parameters/diag_read_hw
cat /sys/kernel/debug/clk-audcp-diag/identity
printf '\nRecent dmesg\n'
dmesg | tail -160
