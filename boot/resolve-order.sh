#!/bin/sh
# Work out the load order for the audio modules from the module set itself, instead of
# hand-maintaining a list. Runs depmod over a scratch copy of every .ko, asks for the
# dependency closure of the audio entry points, and prints them dependencies-first.
set -eu

MODS=${1:-/repo/work/mod618}
KVER=${2:-6.18.54-7552n-probe1+}
OUT=${3:-/repo/boot/module-order-618.txt}

SCRATCH=$(mktemp -d)
mkdir -p "$SCRATCH/lib/modules/$KVER"
cp "$MODS"/*.ko "$SCRATCH/lib/modules/$KVER/"
depmod -b "$SCRATCH" "$KVER"

python3 - "$SCRATCH/lib/modules/$KVER/modules.dep" "$OUT" <<'PY'
import sys
from pathlib import Path

dep = Path(sys.argv[1]).read_text().splitlines()
out = Path(sys.argv[2])

# target -> prerequisites
deps = {}
for line in dep:
    if ':' not in line:
        continue
    tgt, rest = line.split(':', 1)
    name = Path(tgt).name
    deps[name] = [Path(p).name for p in rest.split() if p]

# entry points we actually want loaded, in the order we want them probed
roots = [
    # Power supplies must be present before charger-manager starts.  Keep the
    # board's real fuel-gauge/charger pair ahead of the audio roots; AW32257 is
    # intentionally not included because 7552N uses the TI BQ2560x at 0x6b.
    'sprd_battery_info.ko',
    'ump96xx_fuel_gauge.ko',
    'bq2560x-charger.ko',
    'sprd-charger-manager.ko',
    'agdsp_pd.ko',
    'audio_sipc.ko',
    'audio_mem.ko',
    'audio-pipe.ko',
    'audio-dsp-dump.ko',
    'snd-soc-sprd-codec-ump9620-power-dev.ko',
    'snd-soc-sprd-codec-ump9620-power.ko',
    'snd-soc-sprd-codec-ump9620.ko',
    'snd-soc-sprd-vbc-v4.ko',
    'snd-soc-sprd-vbc-fe.ko',
    'snd-soc-sprd-tdm.ko',
    'snd-soc-sprd-pdm-r2p0.ko',
    'snd-soc-sprd-dummy-codec.ko',
    'snd-soc-fsa4480.ko',
    'snd-soc-sprd-pa-aw87xxx.ko',
    'sprd-dmaengine-pcm.ko',
    'sprd-compr-2stage-dma.ko',
    'sprd-platform-pcm-routing.ko',
    'snd-soc-sprd-card.ko',
]

order = []
seen = set()


def visit(n):
    if n in seen:
        return
    seen.add(n)
    for d in deps.get(n, []):
        visit(d)
    order.append(n)


for r in roots:
    if r not in deps:
        print(f'warning: {r} not in modules.dep', file=sys.stderr)
        continue
    visit(r)

# Two module files are entangled and both have to be in the kernel before their
# dependants:
#   snd-soc-sprd-pa-aw87xxx exports aw87xxx_set_profile, which the card's speaker hook
#       calls; the card cannot load without it.
#   snd-soc-sprd-card carries sprd-asoc-common.o, which exports arch_audio_* /
#       get_agcp_* that vbc / tdm / codec link against.
# So: amplifier first, then the card, then everything else. The card's own probe can
# only succeed once the codecs are bound, so /init rebinds sound@0 once at the end.
FIRST = ('snd-soc-sprd-pa-aw87xxx.ko', 'snd-soc-sprd-card.ko')
POWER = (
    'sprd_battery_info.ko',
    'sprd-charger-manager.ko',
    'ump96xx_fuel_gauge.ko',
    'bq2560x-charger.ko',
)
# Probe the real battery/charger stack before any unrelated device drivers.
# depmod cannot express the DT-only relationship between charger-manager and
# the gauge/charger, so make that policy explicit here.
all_order = order
order = [m for m in POWER if m in all_order]
order += [m for m in FIRST if m in all_order]
order += [m for m in all_order if m not in POWER and m not in FIRST]

out.write_text('\n'.join(order) + '\n')
print(f'{len(order)} modules, dependencies first')
for n in order:
    print(' ', n)
PY

rm -rf "$SCRATCH"
