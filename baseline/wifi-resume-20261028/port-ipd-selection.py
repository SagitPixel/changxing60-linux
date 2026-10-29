from pathlib import Path
import subprocess

root = Path('/k/linux')
# Remove only our experimental WLAN workarounds; HEAD includes the other
# pre-existing port changes, including SAE support.
for rel in ['drivers/unisoc_platform/sprd_wlan_combo/sc2355/cmdevt.c',
            'drivers/unisoc_platform/sprd_wlan_combo/common/cfg80211.c',
            'drivers/unisoc_platform/sprd_wlan_combo/common/common.h']:
    (root / rel).write_bytes(subprocess.check_output(['git', '-C', str(root), 'show', 'HEAD:' + rel]))

header = root / 'include/misc/marlin_platform.h'
s = header.read_text()
needle = 'enum wcn_chip_id_type wcn_get_chip_type(void);'
assert s.count(needle) == 1
s = s.replace(needle, needle + '\n/* Read the Marlin3Lite IPD vendor ID while WCN is powered. */\nint wcn_get_ipd_vendor_id(void);')
header.write_text(s)

p = root / 'drivers/unisoc_platform/sprdwcn/platform/wcn_boot.c'
s = p.read_text()
needle = 'EXPORT_SYMBOL_GPL(wcn_get_chip_type);'
assert s.count(needle) == 1
helper = '''

/* Same read-clock sequence and block-6 IPD field as the 7552N stock BSP.
 * These writes enable reading; no eFuse programming control is touched.
 * Callers hold WCN power: firmware download, then WLAN initialization.
 */
int wcn_get_ipd_vendor_id(void)
{
\tstatic DEFINE_MUTEX(ipd_lock);
\tstatic int cached_id = -1;
\tstatic const struct { u32 reg, mask; } clocks[] = {
\t\t{ 0x4083c32c, BIT(22) },
\t\t{ 0x4083c024, BIT(11) },
\t\t{ 0x4083c050, BIT(18) },
\t\t{ 0x40858040, BIT(0) },
\t};
\tstruct wcn_match_data *match = get_wcn_match_config();
\tu32 raw;
\tint ret, i;

\tif (!match || !match->unisoc_wcn_m3lite)
\t\treturn -EOPNOTSUPP;
\tmutex_lock(&ipd_lock);
\tif (cached_id >= 0) {
\t\tret = cached_id;
\t\tgoto out;
\t}
\tfor (i = 0; i < ARRAY_SIZE(clocks); i++) {
\t\tret = sprdwcn_bus_reg_read(clocks[i].reg, &raw, sizeof(raw));
\t\tif (ret < 0)
\t\t\tgoto out;
\t\tif (!(raw & clocks[i].mask)) {
\t\t\traw |= clocks[i].mask;
\t\t\tret = sprdwcn_bus_reg_write(clocks[i].reg, &raw, sizeof(raw));
\t\t\tif (ret < 0)
\t\t\t\tgoto out;
\t\t}
\t}
\tret = sprdwcn_bus_reg_read(0x40859030, &raw, sizeof(raw));
\tif (ret < 0)
\t\tgoto out;
\tcached_id = (raw >> 29) & 3;
\tret = cached_id;
\tpr_info("WCN IPD vendor=%d (XPE=%d)\\n", ret, ret == 1);
out:
\tmutex_unlock(&ipd_lock);
\treturn ret;
}
EXPORT_SYMBOL_GPL(wcn_get_ipd_vendor_id);
'''
s = s.replace(needle, needle + helper)
a = s.index('static int btwifi_download_firmware(void)')
b = s.index('\nstatic int wcn_get_syscon_regmap', a)
t = s[a:b]
t = t.replace('u32 sec_img_magic, tx_img_size;', 'u32 sec_img_magic, tx_img_size;\n\tu32 variant_offset = 0;')
needle = '\tcount = (tx_img_size + PACKET_SIZE - 1) / PACKET_SIZE;'
assert t.count(needle) == 1
t = t.replace(needle, '''\t/* Stock 3 MiB containers hold the XPE image at 0x180000.
\t * Selecting an XPE INI with the first (non-XPE) image eventually
\t * trips the firmware's periodic IPD check in cmd_tx.c:2374.
\t */
\tif (get_wcn_match_config()->unisoc_wcn_m3lite &&
\t    tx_img_size > 0x180000) {
\t\terr = wcn_get_ipd_vendor_id();
\t\tif (err < 0 || (err == 1 &&
\t\t    tx_img_size - 0x180000 < M3L_FIRMWARE_MAX_SIZE)) {
\t\t\tif (sec_img_magic == SEC_IMAGE_MAGIC)
\t\t\t\tvfree(tx_img_ptr);
\t\t\trelease_firmware(firmware);
\t\t\treturn err < 0 ? err : -EINVAL;
\t\t}
\t\tif (err == 1) {
\t\t\tvariant_offset = 0x180000;
\t\t\ttx_img_size = M3L_FIRMWARE_MAX_SIZE;
\t\t}
\t\tpr_info("WCN firmware IPD=%d offset=0x%x length=%u\\n",
\t\t\terr, variant_offset, tx_img_size);
\t}

''' + needle)
needle = 'memcpy(buf, tx_img_ptr + len, trans_size);'
assert t.count(needle) == 1
t = t.replace(needle, 'memcpy(buf, tx_img_ptr + variant_offset + len, trans_size);')
s = s[:a] + t + s[b:]
p.write_text(s)

p = root / 'drivers/unisoc_platform/sprd_wlan_combo/sc2355/hw_param.c'
s = p.read_text()
a = s.index('/*\n * Marlin3Lite AB')
b = s.index('#define SYSTEM_WIFI_XPE_CONFIG_FILE', a)
s = s[:a] + '/* XPE selection depends on IPD eFuse, not the AB silicon revision. */\n' + s[b:]
a = s.index('int sc2355_get_nvm_table(')
t = s[a:]
t = t.replace('char *prj_name = get_project_name();', 'char *prj_name = get_project_name();\n\tint ipd;\n\tconst char *config;')
old = '''\t} else if (wcn_get_chip_type() == WCN_CHIP_ID_AB) {
\t\twl_info("%s, chip id of marlin3 lite is %d, open %s\\n",
\t\t\t__func__, wcn_get_chip_type(),
\t\t\tSYSTEM_WIFI_XPE_CONFIG_FILE);
\t\treturn hw_param_nvm_parse(priv, SYSTEM_WIFI_XPE_CONFIG_FILE, (void *)p);
\t}
'''
assert t.count(old) == 1
new = '''\t}
\tipd = wcn_get_ipd_vendor_id();
\tif (ipd != -EOPNOTSUPP) {
\t\tif (ipd < 0)
\t\t\treturn ipd;
\t\tconfig = ipd == 1 ? SYSTEM_WIFI_XPE_CONFIG_FILE : SYSTEM_WIFI_CONFIG_FILE;
\t\twl_info("%s: chip=%d IPD=%d file=%s\\n", __func__,
\t\t\twcn_get_chip_type(), ipd, config);
\t\treturn hw_param_nvm_parse(priv, config, (void *)p);
\t}
'''
t = t.replace(old, new)
p.write_text(s[:a] + t)
