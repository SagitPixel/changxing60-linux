# 7552N / 6.18 Wi-Fi 接手记录（2026-10-28）

历史记录：当前已修复并完成 2.4GHz / 5GHz 客户端验收，见 `WIFI-STATUS-2026-10-29.md`。
以下“正在测试”及 legacy_fw_compat 内容是当时状态，不是当前操作方案。

当前主机仓库 D:/Changxing60linux；实际内核树在 Docker 卷 changxing60-linux618 的 /k/linux，输出 /k/build。Windows work/linux-e5 不是正在编译的树。禁止根据文件名推断镜像里的内核版本。

## 已确认

- 用户已手动恢复 misc。再次接手时 Android 槽 A 正常。完整 1MiB 备份在 baseline/wifi-resume-20261028/misc-restored.img，SHA256 92d376bfa39cc227c55c13cf7c0bc959209dc7514b14094f8545a67e66d6a1e2。
- 已对实际块设备使用固定 32 字节上限写 BCB，写后比较整块 misc；2048..2079 之外未变。新 trial 由恢复后的实际记录派生，保留 A 的 successful 标志，B 未确认、tries=2。刷机与重启分开执行。校验报告同目录 flash-verification.json、keep-flash-verification.json。
- Android 上 SDIO 控制器 22220000 对应 mmc2；6.18 对应 mmc1。不要按 mmc 编号判断物理控制器。
- Android 原厂 vddwcn 是 1.2V WCN 电源，vddsim2 是 1.8V，由 sprd-marlin3 使用；vddsdio/vddsdcore 是可插拔 SD 槽的电源。不得给 Wi-Fi host 猜接这些 regulator。原厂 DT 没有 Wi-Fi vmmc/vqmmc supply。
- 原 WCN DT 解析因缺失 GNSS dump 属性提前返回，probe 却吞掉非 DEFER 错误继续成功；电源/时钟/GPIO 完全未解析。已把缺失的调试布局与必要资源分开，禁止缺失布局时执行 GNSS dump。必要资源解析错误必须使 probe 失败。
- WCN 的真实 regulator/GPIO 初始化后，6.18 已实际识别 SC2355，SDR104 208MHz、4bit、1.8V；WCN 固件版本与 Android 相同（MARLIN3_20A_RLS2_W24.29.5，2024-07-19）。无须猜测强制 1.8V。
- 在 #64 + 连续缓冲区 TX 对照中，iw scan 返回 0，发现 42 个 BSS（baseline/wifi-takeover-20261028/tx-copy-run.txt）。这证明至少一次真实扫描成功，不代表重启/热点已经稳定。
- stock INI 文件在 Android /odm/etc，4 个文件与 work/firmware 内容哈希完全相同。必须随 initramfs 提供，不能等 switch_root 后才找到。
- 后续其他模型曾把较旧 #37 内核与后续模块混装；该次运行不作为 #64 测试结果。曾 rmmod WCN 造成内核 UAF/Oops，不得热卸载模块。换模块必须制作配套镜像再启动。

## 当前未解决

- WCN 首次 AUTO 初始化通常成功，关电重载后偶发卡在 SYNC_CALI_WRITE_DONE/CP ready、CMD_SYNC_VERSION 超时。保持 SDIO host runtime PM 为 on 的一次运行时对照未修复，不应据此排除全部 PM 问题。
- 原始 SG packet TX 曾 CMD53 超时。已增加 opt-in sdio_tx_copy 参数使用原有线性 TX 路径；一次扫描成功，但根因尚未闭合。
- AP CCMP GTK 添加成功后，default key selection 可触发固件 cmd_tx.c assert。只跳过该动作后，后续 SET_POWER_BACKOFF 仍触发同位置 assert。
- 原厂 5.4 驱动的 power backoff 使用全局 context=NULL，新版使用 vif context。legacy_fw_compat 对照保留功率限制表，改用原厂全局上下文，同时限制 AP CCMP 默认键选择；尚待完整 AP 验收，禁止宣称已经修好。

## 本轮正在测试

- 内核 #64，modules 同配置、已 strip；ramdisk 包含 GNSS/WCN 固件、4 个板级 INI、音频固件和既有显示模块。
- 通过 WCN 原有 keep-power-on 分支避免 AUTO->Wi-Fi 之间立即关电/重载。新 keep_power_on=1 是 opt-in 模块参数，保留原 DT 默认行为。此为对照，功耗及休眠未验收。
- baseline/wifi-resume-20261028/boot-wifi-keep.img，SHA256 5123ecaf3c11626256ba5db5be9362e7dd3c9e582b2813a55207f16f68771471。init 参数：wcn_bsp sdio_tx_copy=1 keep_power_on=1；sprd_wlan_combo legacy_fw_compat=1。
- 验收顺序：确认运行内核/参数 -> 连续多次扫描 -> 恢复原加密热点 -> 实际客户端关联和 DHCP -> 再次启动验证。暂时关闭 AP 的配置已有现场备份 /root/codex-wifi-backup/wireless。

## 边界

不得裸读 AGCP/时钟 MMIO；不得卸载 WCN；不得整分区写 misc；不得硬编码 sda/sdc。Android ADB 必须指定本机串号（`adb devices` 里那台真机；电脑上另有 `emulator-5554`）。新基线的完整补丁/config/刷机审计保存在 baseline/wifi-resume-20261028。
