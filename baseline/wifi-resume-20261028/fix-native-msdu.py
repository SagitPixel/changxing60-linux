from pathlib import Path

p = Path('/k/linux/drivers/unisoc_platform/sprd_wlan_combo/sc2355/cmdevt.c')
s = p.read_text()
needle = '\tdscr->tx_ctrl.sw_rate = (is_special_data == 1 ? 1 : 0);'
assert s.count(needle) == 1
s = s.replace(needle, '''\t/* The 7552N stock SDIO BSP leaves this bit clear for ARP/TDLS.
\t * Its 2024 SC2355 firmware asserts in cmd_tx.c when the newer
\t * special-packet software-rate flag is set. Keep the alternative
\t * behind the existing board compatibility switch for comparison.
\t */
\tdscr->tx_ctrl.sw_rate =
\t\t(sprd_legacy_fw_compat && hif->hw_type == SPRD_HW_SC2355_SDIO) ?
\t\t0 : is_special_data;''')
p.write_text(s)
