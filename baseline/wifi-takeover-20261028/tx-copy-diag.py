from pathlib import Path
p=Path('/k/linux/drivers/unisoc_platform/sprdwcn/sdio/sdiohal_tx.c');s=p.read_text();s='#include <linux/moduleparam.h>\n'+s
idx=s.index('int sdiohal_tx_thread') if 'int sdiohal_tx_thread' in s else -1
assert idx>=0
s=s[:idx]+'/* Controlled fallback to the existing linear TX path while validating SG. */\nstatic bool diag_tx_copy = true;\nmodule_param(diag_tx_copy, bool, 0644);\nMODULE_PARM_DESC(diag_tx_copy, "Diagnostic: use linear SDIO TX rather than packet SG chains");\n\n'+s[idx:]
assert s.count('if (p_data->adma_tx_enable) {')==1
s=s.replace('if (p_data->adma_tx_enable) {','if (p_data->adma_tx_enable && !diag_tx_copy) {')
p.write_text(s)
