from pathlib import Path
p=Path('/k/linux/drivers/unisoc_platform/sprd_wlan_combo/sc2355/cmdevt.c');s=p.read_text();a=s.index('int sc2355_set_power_backoff(');b=s.index('\nint sc2355_set_scan_power_backoff(',a);t=s[a:b]
t=t.replace('if (data)\n\t\tmemcpy(&p->backoff, data, sizeof(*data));', "/* The downstream table contains tuning for other OEM projects.\n\t * Stock compatibility uses the existing all-zero reset command:\n\t * retain this board's firmware/INI defaults and cfg80211 regdomain. */\n\tif (data && !sprd_legacy_fw_compat)\n\t\tmemcpy(&p->backoff, data, sizeof(*data));")
assert t!=s[a:b];s=s[:a]+t+s[b:];p.write_text(s)
