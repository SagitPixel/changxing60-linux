from pathlib import Path
p=Path('/k/linux/drivers/mmc/host/sdhci-sprd.c')
s=p.read_text()
old='\t\t/*\n\t\t * The SC2355 is soldered and the slot has no card-detect GPIO:\n\t\t * without MMC_CAP_NONREMOVABLE mmc_rescan() asks the host for a\n\t\t * card-detect state, gets 0 and never sends CMD5 -- the WCN scan\n\t\t * then times out with the chip powered and idle.\n\t\t */\n\t\thost->mmc->caps |= MMC_CAP_NONREMOVABLE;\n'
new='\t\t/* WCN powers the chip after the host\'s initial scan and requests\n\t\t * another scan through mmc_detect_change(). NONREMOVABLE would\n\t\t * make mmc_rescan() return after that first, unpowered attempt.\n\t\t * BROKEN_CARD_DETECTION already makes get_cd() return present.\n\t\t */\n\t\thost->mmc->caps &= ~MMC_CAP_NONREMOVABLE;\n\t\tdev_info(&pdev->dev, "Wi-Fi SDIO: WCN-controlled power and rescans\\n");\n'
assert s.count(old)==1
p.write_text(s.replace(old,new))
print('Removed scan-once behavior from the WCN-controlled SDIO host')
