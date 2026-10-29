from pathlib import Path
p=Path('/k/linux/drivers/unisoc_platform/sprdwcn/platform/wcn_boot.c');s=p.read_text()
a=s.index('\tret = of_property_read_u32(np, "sprd,gnss-cp-start-addr",')
b=s.index('\n\tmarlin_dev->wakeup_ap',a)
s=s[:a]+'\t/* Legacy SC2355 DTs do not describe GNSS diagnostic dump ranges.\n\t * These are not BT/Wi-Fi boot resources: do not skip every regulator,\n\t * GPIO and clock below just because optional dump metadata is absent.\n\t * gnss_dump_mem rejects external dumps without a complete layout.\n\t */\n\tif (of_property_read_u32(np, "sprd,gnss-cp-start-addr", &GNSS_CP_START_ADDR) ||\n\t    of_property_read_u32(np, "sprd,gnss-firmware-max-size", &GNSS_FIRMWARE_MAX_SIZE) ||\n\t    of_property_read_u32(np, "sprd,gnss-dump-packet-size", &GNSS_DUMP_PACKET_SIZE) ||\n\t    of_property_read_u32(np, "sprd,gnss-dump-reg-number", &GNSS_DUMP_REG_NUMBER)) {\n\t\tGNSS_CP_START_ADDR = 0;\n\t\tGNSS_FIRMWARE_MAX_SIZE = 0;\n\t\tGNSS_DUMP_PACKET_SIZE = 0;\n\t\tGNSS_DUMP_REG_NUMBER = 0;\n\t\tdev_info(&pdev->dev, "legacy DT: external GNSS diagnostic dump disabled\\n");\n\t}\n'+s[b:]
s=s.replace('int ret, rc;','int ret, rc = -ENOENT;')
old='\tif (err < 0) {\n\t\tpr_info("marlin parse_dt some para not config\\n");\n\t\tif (err == -EPROBE_DEFER) {\n\t\t\tdevm_kfree(&pdev->dev, marlin_dev);\n\t\t\tpr_err("%s: get some resources fail, defer probe it\\n",\n\t\t\t       __func__);\n\t\t\treturn err;\n\t\t}\n\t}\n'
new='\tif (err < 0) {\n\t\tdev_err_probe(&pdev->dev, err, "WCN resource parsing failed\\n");\n\t\tdevm_kfree(&pdev->dev, marlin_dev);\n\t\tmarlin_dev = NULL;\n\t\treturn err;\n\t}\n'
assert old in s;s=s.replace(old,new)
p.write_text(s)
p=Path('/k/linux/drivers/unisoc_platform/sprdwcn/platform/gnss_dump.c');s=p.read_text();a=s.index('\tGNSSDUMP_INFO("%s entry\\n", __func__);',s.index('static int gnss_ext_dump_mem(void)'))
s=s[:a]+'\tif (!GNSS_CP_START_ADDR || !GNSS_FIRMWARE_MAX_SIZE ||\n\t    !GNSS_DUMP_PACKET_SIZE || !GNSS_DUMP_REG_NUMBER)\n\t\treturn -EOPNOTSUPP;\n\n'+s[a:];p.write_text(s)
