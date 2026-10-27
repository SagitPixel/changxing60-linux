# 把 7552N 接到 e5-linux 上（方案）

2026-10-25 夜。目标：**放弃在厂商 5.4 上继续修音频，改用 `sprd-linux-devs` 的 6.18 主线树，
新增一个 7552N 的 device 层。**

## 为什么换路

今晚在 5.4 上查到的结论（全部实测，见 `docs/FINDINGS.md` 第 24 节）：

- 两边寄存器位定义**完全一致**（和 `sprd-linux-devs/linux` 的 `sound/soc/sprd/unisoc/include/` 逐行比过）
- Android 播放/通话时 DAPM 全 On（`Normal-Playback`/`DAC`/`Digital Power`），我们全 Off
- 卡在 crossbar `S_NORMAL_AP01_P_CODEC`：控件写 `on` 成功，但对应 DAPM 控件 `Off in 1 out 0`，
  路由表里两条都在且无条件、已注册、dmesg 无任何路由错误
- 换回全原厂模块、换设备树、照抄 Android 的 326 个控件值 —— 都无效

**同样的驱动代码在 6.18 上音频是通的，在 5.4 上不通。** 而这台机器的 5.4 组合
（厂商内核 + 厂商模块 + realme C51/C53 重编模块）没有任何成功先例可对照。

## 参照物

| | VIPME M8（已跑通） | 7552N（我们） |
|---|---|---|
| SoC | UMS9620 / qogirn6pro | UMS9620 / qogirn6pro |
| 板号 | `ums9157_2h10_native` | `ums9620_2h10_feimao` |
| Android 内核 | 5.4.210 | 5.4.254 |
| 功放 | AW87xxx (I²C 6-0058) | AW87xxx（已确认，`snd_soc_sprd_pa_aw87xxx` 已加载） |
| 听筒 | **无独立听筒**，手机/扬声器共用外放 | **有独立听筒**（用户确认听到底噪） |
| 屏幕 | LCD st7796u + PWM 背光 | 有屏（型号待确认） |

M8 的可复用资产：`linux_device_m8` 的构建脚本、`port/audio-legacy-dt.c`、
`boot-probe`/`flash-probe` 那套「只写 boot_b + misc 32 字节、失败自动回落 Android」的安全机制。

## 阶段与检查点

每个阶段都有可验证的产出，不能跳。

### 阶段 0：收集原厂基线（只读，可以今晚做）

- [ ] 本机 DT/DTBO 完整提取（`/proc/device-tree` 已在 Android 上可读）
- [ ] 原厂 `boot_a` / `vendor_boot_a` 里的 defconfig（`/proc/config.gz`）
- [ ] 分区表、启动槽、根分区类型
- [ ] 本机 kernel modules 清单及哈希（`work/kmod-orig` 已有 167 个）
- [ ] 屏幕/触控/充电芯片型号（可以后面再说，音频不需要）

产出：`docs/7552N-BASELINE.md`

### 阶段 1：能用 6.18 编出 Image（不要求能启动）

- [ ] `work/linux-e5`（`e5-6.18` 分支，正在克隆）
- [ ] 拿 M8 的 defconfig + `e5-linux.fragment` 当起点，改成 7552N 的
- [ ] 写 `ums9620-7552n.dts`：先只放内存、GIC、UART、时钟 —— 够串口出字就行
- [ ] 编出 `Image` + `dtb`

检查点：**编译通过**（不代表能启动）。

**具体起点：抄 `work/m8/build-probe.sh`（75 行，已 clone）。** 它的做法是
`upstream/e5-mainline.config` + 追加机型专属 CONFIG + 公共 cpufreq 配置，然后 `allnoconfig` 合并。

里面已经写好了我们要的值，照抄即可：

```
CONFIG_LOCALVERSION="-7552n-probe1"
CONFIG_CMDLINE="earlycon=sprd_serial,0x20210000,115200n8 console=ttyS1,115200n8 \
  console=tty0 loglevel=7 log_buf_len=4M rdinit=/init panic=10 \
  clk_ignore_unused pd_ignore_unused regulator_ignore_unused fw_devlink=permissive"
CONFIG_SPRD_UMS9620_CLK=y
CONFIG_PINCTRL_SPRD_QOGIRN6PRO=y
CONFIG_SPRD_UMS9620_IPA_PD=y
CONFIG_USB_SPRD_UMS9620_SSPHY=y
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_DUAL_ROLE=y
```

`earlycon=sprd_serial,0x20210000` 是这颗 SoC 的串口地址，先用它拿到日志。

M8 的配置里有、我们要按实际情况取舍的：`CHARGER_BQ2560X_SPRD`（7552N 的充电芯片待确认）、
`SPRD_THERMAL_R5P0`、显示/触控相关。

**产物**：`make Image modules` → `wrap-image.py` 包成 LK 格式的 `Image.lk`。

### 阶段 2：启动到串口/网络

- [ ] 用 M8 的 `make-probe.py` / `flash-probe.py` 思路，做一个只写 boot_b 的镜像
- [ ] 启动失败自动回落 Android（必须保留这个保护）
- [ ] 起来之后先确认 `uname -a`、能进 initramfs

检查点：**串口或 USB 网卡能看到 kernel log**。

### 阶段 3：音频（真正的目标）

- [ ] 移植 `audio-legacy-dt.c`（把厂商 DTB 里的 `agdsp-access` 改成 genpd provider + 九个消费者）
- [ ] 挂载 `sound/soc/sprd/unisoc/`（6.18 树里已有）
- [ ] 声卡注册成功（`/proc/asound/cards` 有 `sprdphone-sc2730`）
- [ ] 播放通、录音通
- [ ] 通话：`FE_ST_VOICE` 场景 + 上下行

检查点：**听筒能出声**。

### 阶段 4：网络与电话（可选，按需）

M8 已证明这条路上基带 AT、ModemManager、短信、通话控制都能跑。我们的 AT 通道经验
（`/dev/stty_nr1`、`mu300-at`）可以直接搬。

## 会作废的东西

诚实记录，免得后面心疼：

- 5.4 的所有 kernel patch：DMA 指针、period timer（无中断）、aw87xxx hook、VBC_VOLUME 上限修复
- `changxing60-audio-load` / `-up` / `-route` 三个脚本（6.18 的模块集和加载顺序完全不同）
- 5.4 的 `/lib/firmware` profile 加载方式

## 会保留的东西

- **全部认知**：`agdsp_access_en` 决定 DMA 能否动、IIS 端口 0/1 要分别给时钟、
  profile 模式编码 `(mode<<24)|(mode<<16)|5`、`VBC_VOLUME` 要写音量+1、
  读 AGCP 寄存器必须先按住电源域否则挂总线
- Android 通话时的 326 个控件快照（`work/calldump.txt`）—— 任何阶段拿来做对照都有效
- 抓取脚本 `tools/cap-call.sh`、`work/cap-dapm.sh`
- `tools/bootlinux-app`（切系统的 App，和内核无关）
- 短信 UCS2 修复、ModemManager/AT 相关的一切

## 风险

1. **6.18 在这颗芯片上可能起不来** —— M8 能起来，但板级差异（PMIC 稳压器 compatible、
   时钟树、USB PHY）都要重来一遍。M8 的记录显示他们前几轮就是卡在这些地方。
2. **屏幕可能不工作** —— 不影响音频，但调试会难受（没显示）。
3. **工作量** —— M8 从 2026-09 到 10 月，多轮 probe 才到音频通。我们不会更快。
