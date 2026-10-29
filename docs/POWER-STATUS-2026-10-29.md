# 7552N 电源驱动接入（2026-10-29）

## 原厂 DT 基线

- `sprd,ump9620-fgu`：PMIC 内置 fuel gauge，目标 power-supply 名称为 `sc27xx-fgu`。
- `sprd,ump9620-fast-chg`：PMIC fast-charge 子节点。
- `ti,bq2560x_chg`：I²C `0x6b` 外置充电芯片。
- `charger-manager`：`cm-fuel-gauge=sc27xx-fgu`，`cm-hardware-psy=bq2560x_charger`。

当前运行的 6.18 镜像 `/sys/class/power_supply` 为空，说明不是用户态显示问题，而是电源驱动没有进镜像/没有绑定。

## 本轮改动

1. 将已有的 BQ2560x 厂商驱动接入 `drivers/power/supply`，匹配 `ti,bq2560x_chg`。
2. 增加 6.18 API 适配：`probe/remove` 回调、`fwnode` 注册配置、GPIO 输入标志。
3. 将主充电 power-supply 名称修正为 `bq2560x_charger`，与原厂 DT 的 charger-manager 属性一致。
4. 7552N 配置启用 `CONFIG_FUEL_GAUGE_UMP96XX=m`、`CONFIG_CHARGER_BQ2560X_SPRD=m`，关闭不匹配的 `CONFIG_CHARGER_AW32257`。
5. 将 BQ2560x 加入 initramfs 模块依赖顺序，位于 FGU 之后、charger-manager 之前。

## 验证边界

在本机 WSL 的 Linux 6.18 工具链中，`charger-manager`、UMP9620 FGU 和 BQ2560x 三个目标均通过 C 编译；由于没有完整 `Module.symvers`，单独模块构建的 modpost 未完成，不能代替正式内核构建。

尚未刷机验证。正式镜像完成后，验收顺序是：

1. `/sys/class/power_supply/` 出现 `sc27xx-fgu` 与 `bq2560x_charger`；
2. 读取 `status/capacity/voltage_now/current_now/present/online/health`；
3. 插拔 USB 充电器，对比 `online/status/current_now` 和 dmesg 的 probe/defer；
4. 确认 charger-manager 不再报告找不到 `bq2560x_charger`。

## 本轮构建产物

- `work/boot-618-power.img`：64 MiB，未刷机。
- `boot/module-order-618.txt` 的前四项为：`sprd_battery_info.ko`、
  `ump96xx_fuel_gauge.ko`、`bq2560x-charger.ko`、`sprd-charger-manager.ko`。
- 镜像内已确认包含上述四个模块，且不再包含不匹配本机硬件的
  `aw32257_charger.ko`。
- 镜像 SHA-256：
  `BD7B1B411FEF5A5D1110DBFE57B920787C8AB2F870271039A1227A30557358D8`。

完整 modules 构建使用了 `KBUILD_MODPOST_WARN=1`，仅保留了音频模块已有的
`ums9620_audcpglb_gate_read` 未解析警告；本轮四个电源模块均已生成并打入镜像。
这还不是硬件验收，必须启动此镜像后读取 `/sys/class/power_supply` 才能确认实际绑定。

## 首次启动反馈与修正

首次刷入后确认 BQ2560x 已 probe，但 FGU 因 `cm_notify_event` 未解析而加载失败，
因此 `/sys/class/power_supply` 仍为空。根因是 initramfs 中把 FGU 放在
`charger-manager` 之前；该符号由 charger-manager 导出。已改为：

`sprd_battery_info.ko → sprd-charger-manager.ko → ump96xx_fuel_gauge.ko → bq2560x-charger.ko`

重新生成的镜像为 `work/boot-618-power-v2.img`，SHA-256：
`C1D951891DB02782B6526B3BE11D68EAB9CD19022392C06A0F657681EFF099CE`。

v2 启动后已确认 `sc27xx-fgu` 注册并能读出容量、电压、电流；但 BQ 驱动仍因
`otg-vbus` 子节点位于 I2C charger 下、旧代码却只查找 platform device，probe
返回 deferred，导致 `bq2560x_charger` 没留下。已改为以 I2C charger 自身作为
regulator owner，生成 `work/boot-618-power-v3.img`，SHA-256：
`0C0E700F6434ADCCFA1ED1EF4715F9B1E82F3CCE791AB54B844AAC58509488E8`。

v3 实际刷入后仍出现旧的 `otg parent node device` 日志，核对发现 out-of-tree
构建目录保留了旧 `.ko`，不是源码修正失效。已改用源码目录中重新链接的模块并生成
`work/boot-618-power-v4.img`，SHA-256：
`5214E1E81A7D52294B25FE5B90B26D2AE6A7810BBB1D73FEF9F1599071D11A07`。

## v4 硬件验收

v4 启动成功，且 I²C 设备已绑定 `bq2560x_chg`。当前系统已注册：

- `sc27xx-fgu`：`capacity=954`（约 95.4%）、`voltage_now=3990000`
 （3.99 V）、`current_now=-2000`（约 -2 mA，放电）。
- `battery`：charger-manager 汇总节点，能提供状态、容量、电压、电流、温度、
  充电电压/电流上限等完整属性。
- `bq2560x_charger`：已绑定，当前 `status=Not charging`、`online=1`。

`/sys/kernel/debug/devices_deferred` 中已没有 `6-006b` 或 charger 条目。
下一步只需插入墙充并对比插入前后 `status/online/current_now/voltage_now`，即可完成
充电状态的硬件验收。

## 屏幕启动日志回归（已定位）

用户反馈机身屏幕不显示启动日志。现场确认运行内核退回 #37（Oct 27），
`/dev/dri/card0`、`/dev/fb0` 均不存在，init 留有 `stage=display-missing`。
上面的 power-v1 至 v4 使用了过期 `boot-618-slotb.img` 作为底包，并用仅含音频
和电源的加载列表替换了完整列表，因而不能作为保留显示/Wi-Fi/基带的正式基线。
电源 probe 成功不代表这些版本通过整机验收。

修正工具：`tools/build-power-on-baseline.py`。以已验证的
`work/boot-wifi-modem-618.img` 为底包，保留其 #64 内核、init、显示、Wi-Fi、
基带模块和加载顺序，仅添加/替换四个电源模块及电源加载项。
构建后逐文件断言未改动其它 ramdisk 内容，并检查所有加载项都有对应模块。

修复镜像：`work/boot-power-display-618.img`。

- 镜像 SHA256：`f213102525204cbd6a590a81e93cfc72f14d1fc3e565cfd4b644849795cd0fc5`
- 内核 SHA256：`197075a80199c7b9554a42561bd6edaf784f0c35222b294aa5a3d6e3b307033a`
- 已写入 boot_b 并完整读回校验，随后重启。
- misc 已备份；仅更新偏移 2048 的 32 字节 B 槽试启动记录，其余内容对比未变。

系统 logd、logread、ubus log.read 和 dmesg 均有正常输出，用户明确指的是
机身屏幕，不是 LuCI 网页日志。

### 修复后的现场验收

- `uname`：`6.18.54-7552n-probe1+ #64`。
- 模块加载：`loaded=43 failed=0`，`stage=display-ok wait=5s`。
- `/proc/fb`：`0 sprddrmfb`，`/dev/dri/card0` 存在；vtconsole 已绑定，背光亮度 69。
- 电源节点保留：`battery`、`sc27xx-fgu`、`bq2560x_charger`；本轮采样为
  `95% / 3988000 uV / -3000 uA / Discharging`。
- `br-wifi`、`br-lan` 和 `sipa_eth0` 均 UP，并有 IPv4 地址；未做本轮吞吐验收。
- 用户已现场确认：能看到机身屏幕的启动日志。

结论：本次屏幕回归来自错误镜像基线及加载列表覆盖；恢复 #64 完整基线并保留
电源模块后，显示和电源读取同时正常，未发现电源驱动与显示的兼容性冲突。
后续电源镜像应使用 `tools/build-power-on-baseline.py` 在完整已验证镜像上增量打包，
不要再使用早期 `boot-618-slotb.img` 与仅含音频/电源的列表覆盖整机基线。

## 充电输入与板温修复（2026-10-29 晚）

### 根因与改动

1. 移植后的 SS PHY 用 `EXTCON_USB` 报告 VBUS，只调用 connect/disconnect，
   没有维护 charger-manager 原先依赖的 `usb_phy.chg_state/chg_type`。
   给 charger-manager 增加只读、默认关闭的 `legacy_usb_extcon` 参数；在本机
   initramfs 显式传入 `legacy_usb_extcon=1` 后，从 PHY 的 extcon 注册插拔通知，
   并补做开机时已插线的状态检查。
2. BQ 驱动的 ONLINE 原先返回 `chip_type`。修正为芯片 REG8 的电源状态，
   排除 OTG；新增从 REG8 解码 SDP/CDP/DCP 的 USB_TYPE。兼容路径读取本机 DT
   `cm-hardware-psy` 指定电源节点的 USB_TYPE，不虚构 PHY 的 BC1.2 检测结果。
3. 本机 DT 没有 `cm-thermal-zone`，但已有可读的 `board-thmzone`。
   增加 `legacy_board_thermal_zone` 参数并在本机传入该名称，沿用原温控框架、
   JEITA 和电流策略；没有用用户态强写电流/电压寄存器替代策略。
4. `charge-fix` 的旧 `device/registers` 节点已不存在。6.18 下改为 no-op，
   旧脚本留在设备的 `.legacy-5.4` 备份；删除其 cron 项，同时给
   `/etc/init.d/changxing60-hw` 加 6.18 跳过条件，避免每次开机重新加回。
   原有 bootdiag 定时任务保留，原 init 脚本已备份。

可审阅源码补丁：`kernel/patches/power-charging-7552n.patch`。
`work/build-7552n/charger.py` 已接入该补丁，并通过从原始厂商源准备及重复应用检查。

### 构建、刷入与验收

- 镜像 `work/boot-power-charge-618.img`，SHA256：
  `bc1bb5806203fcefbffb6d045dfccf210190ae90846920a1bf6c956858a680f5`。
- 使用 `tools/build-power-on-baseline.py --legacy-charging`；保留已验证的 #64
  内核以及显示、无线、基带文件，仅更换电源模块与对应 init 参数。
- 内核 SHA256 仍为
  `197075a80199c7b9554a42561bd6edaf784f0c35222b294aa5a3d6e3b307033a`。
- 两个修改模块正常完成 C 编译、链接和 modpost；本次模块构建没有使用
  KBUILD_MODPOST_WARN 绕过未解析符号。
- boot_b 刷写后完整哈希回读通过；misc 已备份，只有偏移 2048 的 32 字节
  标准 B 槽试启动记录发生更新，范围外字节校验未变。
- 启动后仍为 #64，`loaded=43 failed=0`、`display-ok`；用户确认屏幕正常。
- 初始插线：`Charging`，FGU 实测约 +439mA，USB 类型 SDP。
- 用户拔线：`Discharging`、battery.online=0、BQ online=0，实测放电约
  -462～-500mA；插拔事件从 extcon 到 charger-manager 有日志对应。
- 用户重新接线后恢复 `Charging`、online=1、SDP；最终连续四次采样电流
  为 +104、+185、+153、+168mA。电脑 SDP 的输入限流为 500mA，不能将其
  当成墙充最大能力测试。
- `TEMP_AMBIENT` 与 board-thmzone 的实际读数对应（验证中约 39.5～44.5°C），
  本次启动的 `Can not to get board temperature` 次数为 0。
- 热点可 SSH 连接，蜂窝 `ping -I sipa_eth0` 为 3/3，0% 丢包。
- crontab 目前仅保留 bootdiag，charge-fix 不再有等待进程。

源码前后、模块前版、用户态前版与运行日志存于 `baseline/power-fix-20261029/`；
最终采样与 dmesg 在其 `verified/` 子目录。

### 仍未验收或尚未修复

- 本轮没有验证墙充 DCP、快充或 USB-PD；没有据 SDP 测试宣称它们已经正常。
- 四个 SoC thermal 设备的 deferred probe、SIPA 休眠和 Wi-Fi LUT 丢包仍待修复。
- PHY 原有插拔诊断日志仍打印其旧的 `chg_type=0`；实际分类应以本轮新增的
  BQ USB_TYPE 与汇总 battery.usb_type 为准。
- FGU 个别属性语义（例如 constant_charge_voltage）、CPU 调频/空闲功耗优化
  仍未作为本轮修复完成项。
