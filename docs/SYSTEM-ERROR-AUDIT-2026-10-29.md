# 7552N 系统错误审计（2026-10-29，约 21:32 中国时间）

本轮只读抓取并分析，没有修改设备配置、驱动、分区、充电参数或清空日志。
运行内核为 6.18.54 #64，已运行约 3 小时 31 分钟。

## 采集范围

原始留档：`baseline/system-audit-20261029-213158/`。

- `dmesg.txt`：4,194,278 字节，54,805 行。
- `syslog.txt`：142,820 字节。
- `stages.txt`：本次启动的阶段记录。
- `state.txt`、`processes.txt`、`services.json`：电源、网络、显示、服务等现场状态。
- `bootdiag-729.txt`：boot_id 与当前启动一致的早期诊断；`pstore-summary.txt`
  是旧 Android 记录，不作为当前内核崩溃证据。
- `kernel-errors.txt`：现存内核日志中优先级 0～3 的全部 1,487 行。
- `kernel-error-candidates.txt`：同时包含关键词匹配的 2,019 行；匹配 timeout
  的成功通信参数也可能在其中，不能将候选行数当作独立故障数。
- `syslog-errors.txt`、`error-groups.json`：系统错误级日志与内核归并计数。

内核日志已覆盖启动初期，现存时间范围约 uptime 2456～12663 秒；因此这不是
从开机起的完整事件统计。原始日志可能包含网络标识等个人信息，分享前需脱敏。

## 推荐修复顺序

| 优先级 | 问题 | 证据与影响 | 下一步 |
|---|---|---|---|
| P1 | 充电输入检测/启停尚未闭环 | Type-C/extcon 显示 USB=1，但 battery=Discharging、usb.online=0、输入电流限制为 0；FGU 电流为负。BQ ONLINE 的实现返回 chip_type，不能据此确认外部电源 | 对照原厂 BC1.2/Type-C/charger-manager 事件链及实际芯片状态，验证插拔和充电电流；不靠强写充电寄存器绕过 |
| P1 | 板温未接入 charger-manager | `Can not to get board temperature` 707 次。真实 board-thmzone 约 41.6～42°C，而管理器 TEMP_AMBIENT=25°C；DT 无 cm-thermal-zone | 接通真实板温来源，核实温控策略；电池自身温度已可读，不等于板温缺口已解决 |
| P2 | ~~SoC 温控设备仍 defer~~ **已修（2026-10-30，`#66`）** | 根因是 efuse provider 无驱动（`sprd,qogirn6pro-efuse` 不在 match 表）；补丁后四个控制器全部绑定，zone 从 5 个变 24 个 | 已完成，见 `THERMAL-STATUS-2026-10-30.md`；trip point/降频仍未接（`virtual-thermal`） |
| P2 | 旧 charge-fix 定时任务不适配 | 每分钟执行；等待 `/sys/class/power_supply/bq2560x_charger/device/registers`，但新驱动没有该路径；可见 process already running | 在电源修复时一并移除/替换旧任务，避免每分钟空等及误用旧寄存器参数 |
| P2 | SIPA 休眠反复返回 EAGAIN | `thread prepare suspend err` 31 次、`task fill_recv 0` 31 次；源码在 RX FIFO 仍需补充时拒绝休眠并延长唤醒 500ms | 观察流量结束后接收队列能否清空，验证休眠与恢复；不能据此判断蜂窝网络已断 |
| P2 | Wi-Fi 断连附近的 LUT/发包异常 | bssid not found 169 次、sta disconn 169 次、TX Err 166 次、CMD_TX_DATA 固件错误 6 次、BA reorder timeout 281 次 | 对照客户端连接/离开及流量时间线，确认是否只是在客户端离开后继续发包；当前热点仍 UP，不算固件崩溃证据 |
| P3 | 调试日志过量 | SDIO power 日志两类合计 20,962 行，WCN loopcheck 也大量输出，4MiB ring 已丢失启动期 | 在根因调查后降低/限速普通调试日志，保留真正错误与启动留档 |
| P3 | bring-up 电源策略未收敛 | 启动参数保留 clk/pd/regulator_ignore_unused，WCN keep_power_on=Y；CPU cpufreq 目录缺失 | 分项验证功耗管理，不能直接全部关闭开关，以免重现设备访问/无线掉电问题 |

## 解释边界

- 当前保留的内核日志未发现 Kernel panic、Oops、BUG 或 SError；不代表已被覆盖
  的时间段绝无异常。tainted=4096 对应加载外部模块，不是本次发生内核警告的证明。
- 主要长期服务均在运行；urandom_seed 已完成并以 0 退出，是一次性任务。
- 显示 framebuffer/DRM、音频声卡与电源设备已注册；43 个启动模块加载成功。
- `audio-card-rebind rc=1` 同时伴随已注册声卡，多半是对已绑定设备重复 bind，
  不应把这一个返回码认定为声卡失效。
- 56360000.audio-codec 未绑定是此前已确认的数字节点角色，不能凭无 driver 链接
  就新增一个虚假 codec 驱动。
- `64a00000.usb` 仍 defer，启动留档有 `Error getting usb-phy -517`；实际使用的
  `25100000.dwc3` UDC 已存在且 USB 网络工作，后者并不因前者 defer 而失效。
- `send 802.1X frame by CMD_TX_DATA`、部分 probe 调试信息虽然用 error 级打印，
  仍需按行为解释，不能一律当失败。
- `charge-fix` 路径缺失说明脚本当前未执行到寄存器写入，不能声称它正在覆盖
  新驱动参数；它仍是应清理的遗留任务。
- `sc27xx-fgu.constant_charge_voltage` 约 4.99V、voltage_max_design=-1、
  time_to_full_now=1 等属性存在可疑语义/兼容性，不能当成实际电池电压或真实剩余
  时间；实际 voltage_now 约 3.737V。应随电源属性审计核对单位与实现。

## 关键源码定位

- `work/linux-e5/drivers/power/supply/bq2560x-charger.c`：ONLINE 返回 chip_type。
- `work/linux-e5/drivers/power/supply/charger-manager.c`：cm_get_board_temperature()
  在无 tzd_batt 时使用 250，cm_init_thermal_data() 从 cm-thermal-zone 查温区。
- `work/linux-e5/drivers/unisoc_platform/net/sipa_v3/sipa_core.c`：
  sipa_thread_prepare_suspend() 的 EAGAIN/500ms 唤醒分支。
- `work/linux-e5/drivers/unisoc_platform/net/sipa_v3/sipa_skb_recv.c`：
  sipa_receiver_prepare_suspend() 的 fill_recv 检查。
- `work/linux-e5/drivers/unisoc_platform/sprd_wlan_combo/sc2355/cmdevt.c`：
  LUT 无效时释放包并返回 EPERM。

建议下一轮先完成充电检测、实际电流和温度策略的闭环，再做无线/SIPA 休眠。
本轮没有实施上述修复。

## 后续修复更新

本日随后已修复充电输入事件链、BQ ONLINE/USB_TYPE 语义和 charger-manager 板温
接入，并停用 6.18 下的旧 charge-fix 定时任务及其开机自动添加逻辑。
已实测插线充电、拔线放电、重新插线恢复充电；板温报错在修复后的本次启动中为 0。
详细证据见 `docs/POWER-STATUS-2026-10-29.md` 的“充电输入与板温修复”一节。
SoC thermal deferred probe、SIPA 休眠、Wi-Fi LUT 丢包及调试噪声尚未修复。
