from pathlib import Path
p=Path('/k/linux/drivers/mmc/host/sdhci-sprd.c')
s=p.read_text()
a=s.index('\n\tif (sprd_host->is_wifi) {\n\t\tstruct device_node *vddsdio, *vddwcn;')
b=s.index('\n\t/* Shared eMMC policy:',a)
s=s[:a]+s[b:]
s=s.replace('\t\tif (sprd_host->is_wifi && !IS_ERR(mmc->supply.vqmmc))\n\t\t\tregulator_set_voltage(mmc->supply.vqmmc, 1800000, 1800000);\n','')
a=s.index('\t\tif (!ret && sprd_host->is_wifi && !IS_ERR(mmc->supply.vqmmc)) {')
b=s.index('\n\t\tif (!ret && sprd_host->fast_hotplug)',a)
s=s[:a]+s[b:]
a=s.index('\tif (sprd_host->is_wifi) {\n\t\tctrl_2 |=')
b=s.index('\n\tsdhci_writew(host, ctrl_2',a)
s=s[:a]+s[b:]
a=s.index('\tif (sprd_host->is_wifi) {\n\t\tu16 c2')
b=s.index('\n}\n',a)
s=s[:a]+s[b:]
a=s.index('\t\tif (sprd_host->is_wifi) {\n\t\t\t/* SC2355 SDIO')
b=s.index('\n\t\tif (ret < 0)',a)
s=s[:a]+'\t\tret = mmc_regulator_set_vqmmc(mmc, ios);'+s[b:]
a=s.index('\n\t/*\n\t * The SC2355 SDIO I/O is fixed at 1.8 V')
b=s.index('\n\t/*\n\t * The card',a)
s=s[:a]+s[b:]
s=s.replace('host->mmc->ocr_avail |= MMC_VDD_32_33 | MMC_VDD_33_34;','host->mmc->ocr_avail = MMC_VDD_30_31;').replace('host->mmc->ocr_avail_sdio |= MMC_VDD_32_33 | MMC_VDD_33_34;','host->mmc->ocr_avail_sdio = MMC_VDD_30_31;')
s=s.replace('\tif (sprd_host->is_wifi && mode != MMC_POWER_OFF)\n\t\tvdd = 0x15;\t/* 3.3-3.4 V bit number */\n','')
needle='\tsdhci_set_power_noreg(host, mode, vdd);'
s=s.replace(needle,needle+'\n\tif (sprd_host->is_wifi)\n\t\tdev_info(mmc_dev(mmc), "wifi-power mode=%u vdd=%u signal=%u\\n", mode, vdd, mmc->ios.signal_voltage);')
needle='\t/* Validate if the request was from software queue firstly. */'
repl='\tif (TO_SPRD_HOST(host)->is_wifi && mrq->cmd &&\n\t    (mrq->cmd->opcode == 5 || mrq->cmd->opcode == 3 ||\n\t     mrq->cmd->opcode == 7 || mrq->cmd->opcode == 11 ||\n\t     mrq->cmd->opcode == 52))\n\t\tdev_info(mmc_dev(host->mmc),\n\t\t\t "wifi-cmd op=%u arg=%08x err=%d resp=%08x\\n",\n\t\t\t mrq->cmd->opcode, mrq->cmd->arg,\n\t\t\t mrq->cmd->error, mrq->cmd->resp[0]);\n'
s=s.replace(needle,repl+needle)
p.write_text(s)
p=Path('/k/linux/drivers/mmc/core/sdio_ops.c');s=p.read_text().replace('\tdump_stack();\n','');p.write_text(s)
print('Native WCN-owned supplies restored; UHS negotiation restored; command diagnostics added')
