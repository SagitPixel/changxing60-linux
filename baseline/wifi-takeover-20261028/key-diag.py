from pathlib import Path
p=Path('/k/linux/drivers/unisoc_platform/sprd_wlan_combo/common/cfg80211.c');s=p.read_text();s=s.replace('#include <linux/rtc.h>','#include <linux/rtc.h>\n#include <linux/moduleparam.h>')
a=s.index('static char type_name')
s=s[:a]+'static bool diag_skip_ap_default_key;\nmodule_param(diag_skip_ap_default_key, bool, 0644);\nMODULE_PARM_DESC(diag_skip_ap_default_key,\n\t"Diagnostic: skip AP CCMP default-key selection after successful key install");\n\n'+s[a:]
needle='\treturn sprd_set_def_key(vif->priv, vif, key_index);'
repl='\tnetdev_info(ndev, "key-default idx=%u crypto=%u uc=%u mc=%u skip=%u\\n",\n\t\t    key_index, vif->prwise_crypto, unicast, multicast,\n\t\t    diag_skip_ap_default_key);\n\tif (diag_skip_ap_default_key && vif->wdev.iftype == NL80211_IFTYPE_AP &&\n\t    vif->prwise_crypto == SPRD_CIPHER_CCMP)\n\t\treturn 0;\n'
assert s.count(needle)==1;s=s.replace(needle,repl+needle);p.write_text(s)
p=Path('/k/linux/drivers/mmc/host/sdhci-sprd.c');s=p.read_text();s=s.replace('mrq->cmd->opcode == 52))','(mrq->cmd->opcode == 52 && mrq->cmd->error)))');p.write_text(s)
p=Path('/k/linux/drivers/mmc/core/sdio_ops.c');s=p.read_text().replace('if (err || fn == 0) {','if (err) {');p.write_text(s)
