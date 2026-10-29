# 7552N Wi-Fi 接手续查（2026-10-29）

## 最终状态：2.4GHz / 5GHz 已实测可用

- 用户分别确认两个频段均能连接，并打开 `192.168.8.1` 的 OpenWrt 后台。DHCP 分配
  `192.168.8.146`；设备到客户端两轮各 5 个 ICMP 包均为 0% 丢包。
- 当前为 5GHz channel 36 / VHT80，WPA2/CCMP，SSID `CHANGXING60-CEAB`，原密码。
  配置已保存。默认 SG TX 已通过收发，init 没有开启 sdio_tx_copy。
- 正式镜像启动后连续开机近 10 小时，现场和早期留档未发现无线固件断言。
- misc 的完整 SHA 与用户恢复备份一致：
  `92d376bfa39cc227c55c13cf7c0bc959209dc7514b14094f8545a67e66d6a1e2`。

根因闭合：原移植版按 AB 芯片 revision 强选 XPE INI；本机原厂模块按 IPD eFuse
选择。新 BSP 实读 **IPD=0**，自动使用普通 `wifi_board_config.ini`。四份原厂文件
均已恢复原样，未长期使用改名覆盖。固件反汇编表明 `cmd_tx.c:2374` 位于按命令计数
周期执行的 IPD 一致性检查；相邻的 KEY/POWER_SAVE/CMD_TX_DATA 不能单独用来归因。

同时补齐原厂 3MiB 固件容器按 IPD 选择 XPE 分段的逻辑（偏移 `0x180000`）。本机
IPD=0 使用第一段；XPE 硬件分支完成代码/构建核对，但没有本机硬件验收。
跳过 CCMP 默认键、清空/改上下文的功率回退、sw_rate 清零实验均已撤回，
`legacy_fw_compat` 参数已删除。

已验证基线：`baseline/wifi-verified-20261029/`。镜像 `boot-wifi-ipd.img` SHA256：
`769277a978da8490d5fd91dccd1b42ff48b178226461aed1355eaf0a18a8d607`。
内核仍为已知可用的 #64，显示内核未替换。目录包含配套模块、init、BCB/完整 misc
备份、内核配置、54 个修改/新增源码的覆盖包、diff、日志与 SHA256SUMS。

可审阅补丁为 `kernel/patches/wcn-7552n-resources-ipd.patch` 和更新后的
`kernel/patches/mmc-sdhci-wifi-power.patch`。WCN 补丁已通过当前源码反向应用检查。
`work/mod618/` 及 rootfs 的 `6.18.54-7552n-probe1+` 无线模块均已同步、备份旧文件。

互联网出口、峰值吞吐、休眠与完整 WCN 断电重载尚未作为通过项目。init 保留
opt-in `keep_power_on=1`。没有热卸载 WCN，也不应这样换模块。

恢复与打包：使用本机已审计的 `baseline/wifi-resume-20261028/flash-linux-checked.py`
及配套记录。旧通用脚本 canonical BCB 哈希与恢复后的原厂记录不同，不可直接套用。
后续打包须保留已验证镜像内的 BCB 与 init 哈希配对，不能用旧默认 init 覆盖它。

以下为排查过程，保留用于复核；“下一步”描述是当时状态。

## 工作位置与保护

实际源码：Docker 卷 `changxing60-linux618` 的 `/k/linux`；构建输出 `/k/build`。Windows 的 `work/linux-e5` 不是当前编译树。

本轮只读取 super 的 vendor/odm/vendor_dlkm 文件系统以核对本机原厂文件。没有写这些分区。misc 原厂完整备份及每轮固定 32 字节 BCB 写入审计保存在 `baseline/wifi-resume-20261028/`；不得整分区写 misc。不得卸载 WCN 模块，已知会发生 UAF。

## 新证据

1. 本机原厂 `/odm/firmware/wcnmodem.bin` 与 `work/firmware/wcnmodem.bin` 完全一致，SHA256 `ea906d728ba4aa0806fd164a298bc14cb02f011f497f108d27ef7b4df99825b9`。GNSS 固件也完全一致，SHA256 `646e49581edd7cc19d6f273d43345168e531759a6086c8d891d0764e5e56f984`。不能再把“固件版本字符串相同”当作唯一依据。
2. 连续缓冲 TX 下扫描返回 0，23 个 BSS；改回原 SG TX 并关闭 legacy_fw_compat 后扫描也返回 0，31 个 BSS。此前的扫描成功不再支持“必须启用 copy 才能扫描”。稳定性仍需后续验证。
3. 原 5GHz WPA2/CCMP 热点仍在启动后断言。2.4GHz/HT20 + 现有兼容开关可以稳定广播一段时间，Windows 实际搜到其加密 SSID，但客户端关联后仍发生同一断言，未完成 DHCP。热点网关为 `192.168.8.1`。
4. 无需客户端也能复现：从设备 `ping -I br-wifi -c 1 -W 1 192.168.8.123` 触发 ARP。日志先出现 `incoming ARP packet` / `CMD_TX_DATA`，紧接着发生 `cmd_tx.c line 2374` 固件断言。此前紧邻的 KEY/POWER_SAVE 日志不足以证明它们是根因。
5. 安全 kprobe 只记录命令号、长度、上下文、前两个控制字节，不读取/打印密钥。位于 `/sys/kernel/debug/tracing`；不是裸读 MMIO。对照 trace 保存在 `ap-command-trace*.txt`、`trace-before-msdu.txt`。

## 原厂二进制核对

原厂模块 `stock-vendor-dlkm/lib/modules/sprd_wlan_combo.ko` 有函数符号，可反汇编。本机原厂 `sc2355_set_power_backoff` 保留传入的 vif，并复制 17 字节配置；先前按另一机型 5.4 源码改成 NULL context、清零 backoff 的实验不属于已验证修复，应在定位后撤回。

原厂 `sc2355_hif_fill_msdu_dscr` 不对 ARP 等特殊帧设置 `tx_ctrl.sw_rate`；移植版会设置该位。两边描述符均为 11 字节，SDIO 的 `01234` 前缀均存在，不能凭前缀存在判断协议不兼容。

## 历史对照镜像（此实验未修复，已撤回）

`boot-wifi-native-msdu.img` 只替换 WLAN 模块，在现有兼容开关开启且为 SDIO 时清除特殊包的 sw_rate 位，其余实验设置暂时保持以控制变量。内核内容不变。

SHA256 `0c6046cde3ede103495309a2f035ce5456caf3b77436f373e8bff07f95809f6c`。刷后读回通过，misc 的 2048..2079 之外逐字节未变；重启独立执行。

当时验收顺序：确认镜像及 misc 恢复 -> 2.4GHz WPA2 热点 -> 同一 ARP 复现 -> 客户端关联/握手/DHCP/数据传输 -> 回撤无效的 power-backoff 实验 -> 5GHz 与重启稳定性。
