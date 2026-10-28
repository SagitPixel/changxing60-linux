# 移植踩坑与进展 — 显示 / UFS

日期：2026-10-27（晚）
机器：畅行 60（ZTE 7552N / P720S20），SoC 展锐 UMS9620（qogirn6pro），
内核 6.18.54 + 厂商驱动移植。

本文只记录两件事：**显示是怎么点亮的**，**UFS 查到了哪一步**。

> **2026-10-28 更新**：UFS 已打通（rootfs 读写校验通过）、显示已稳定——除了 DSI
> reset，还要禁用 5.4 的 `changxing60-screen`（它把背光写成 0%）并给背光加
> `.shutdown`。本文 UFS「未完成」的结论已过期；新踩坑见
> [PITFALLS-2026-10-28.md](PITFALLS-2026-10-28.md)。
重点是踩过的坑和错误判断 —— 这些比结论更值钱。

---

## 一、显示：已点亮

### 结果

```
[drm] sprd_drm_probe()
match add: /soc/dpuvsp/dpu@31000000
skip /soc/ipa-apb/dpu1@31880000: no driver for this crtc
match add: /soc/dpuvsp/dsi@31300000
[drm] sprd_drm_bind()

/dev/dri/card0, /sys/class/drm/card0-DSI-1 (connected, 480x854)
/dev/fb0 (480,854)
```

内屏 480x854 原生分辨率，fbcon 正常显示，背光可调（`/sys/class/backlight/sprd_backlight`）。

### 三层根因 —— 每一层都伪装成「驱动不存在」

**第一层：ramdisk 里没有任何显示模块**

```
CONFIG_UNISOC_DISP=m   → 六个 .ko 都编出来了
boot/module-order-618.txt → 一个都没列
```

驱动从来没被加载过。按依赖顺序补上：

```
sprd_vpu_pw_domain → drm_kms_helper → unisoc-iommu →
drm_client_lib → drm_dma_helper → ocp2131 → sprd-drm
```

**第二层：`sprd_vpu_pw_domain.ko` 没加载**

主 DSI 和 DPU 的 DT 都有 `power-domains = <0x29>`（`sprd,vpu-pd`），
从属 DSI 没有。genpd 没注册 → `dev_pm_domain_attach()` 失败 →
**驱动的 probe 从头到尾不执行**。

表现为「既没绑定、也不在 deferred 队列」的怪状态 —— 因为 probe 根本没进，
连 deferred 都没机会加。

**第三层：`dpu1@31880000` 占着 component match 却没有驱动**

```
DT:  compatible = "sprd,qogirn6pro-dpu1"
驱动: match 表只有 "sprd,qogirn6pro-dpu"
```

设备永远匹配不上 → 永远不 probe → 而它又在 `display-subsystem` 的
match 列表里 → component master 永远等它 → `sprd_drm_bind()` 从不执行
→ `drm_dev_register()` 不产生 card0。

处理：在 match 循环里跳过它。

### 附带修掉的一个真 bug

```c
sprd_dphy_probe() 里 if (dsi->dual_dsi_en) 没有检查 dsi 为 NULL
→ 首次加载直接 NULL deref panic（偏移 0xe20）
```

加了保护后两个 D-PHY 实例都能 probe。

### 坑

`boot/module-order-618.txt` **必须保持 LF**。在 Windows 上用 Python 改过之后
会变成 CRLF，`make-618-image.sh` 会报 `30 module(s) missing` 然后中止。

---

## 二、UFS：未完成，但已经大幅收窄

### 当前状态

```
mmc_host: mmc0 mmc1 mmc2
ufshcd-sprd 22000000.ufs: ...
error -5: Initialization failed with error -5
块设备: 只有 zram0
```

### 已修复的四个缺陷（都已提交）

| 提交 | 内容 |
|---|---|
| `7efc0d7` | DT 的 compatible 是 `sprd,ufshc`，驱动只认 `sprd,ums9620-ufs` → 永不匹配。补上后驱动立刻开始 probe |
| `7efc0d7` | `syscon_regmap_lookup_by_phandle` 失败后 regmap 留的是 `ERR_PTR(-ENODEV)`，而防护写的是 `if (!regmap)` → ERR_PTR 非零照样放行 → `regmap_update_bits` 拿着 -ENODEV 解引用，2.4 秒 Oops。改成 `IS_ERR_OR_NULL` |
| `29fd6a2` | 驱动从来没取过时钟（`devm_clk_get` / `clk_set_parent` 都是 0 次），补上 `clk_set_parent(ufs_hclk, ufs_hclk_source)` |
| `6f6d49e` | 所有 UFS 门控都是 `deviceless` 且硬件使能位为 0（`ufs-eb`/`ufs-cfg-eb`/`ufs-tx-eb`/`ufs-rx-*-eb`），只有 `ufs-pck`/`ufs-cfg` 是开的。显式 `clk_prepare_enable` |

### 已排除的假设（都是实测，不是推理）

| 假设 | 结论 | 依据 |
|---|---|---|
| 输出通路没上电 | 排除 | DAPM 全链 On |
| DMA 没提交 | 排除 | cookie 递增，descriptor 就绪 |
| DSP 没收到命令 | 排除 | SIPC 4→6→7→5 全部 ret=0 |
| **原厂媒体播放走 AP01** | **推翻** | 原厂 dmesg 是 `scene_fast_trigger` + `VBC_DAI_ID_FAST_P`，走 FAST |
| **DAC_OUT 要改成 VBCIF** | **推翻** | 原厂播放中实测就是 `DAC_OUT_FROM_IIS` |
| Profile Select 三个都写同一值 | **推翻** | 原厂只设 `DSP VBC Profile Select = 0x404B0000`，另两个保持 0 |
| SMC / TrustZone 保护 glbregs | 排除 | 5.4 的 PHY SRAM 写之前没有任何 SMC |
| 复位顺序不对 | 排除 | 按 5.4 改成两路同时 assert/deassert，一样 |
| AON 时钟没开 | 排除 | `aon_apb_ufs_clk_en` 实测 `val=0xc0`（已置位），LK 在 Linux 路径也做了 |
| DT 与 Android 不一致 | 排除 | 从全分区备份提取原厂 DTB（169867 字节）逐项对比，运行时 DT 与之一致 |

### 🎯 最关键的发现：ANLG 访问一直是成功的

之前几轮我一直认为「写 `syscon@64380000`（glbregs）的寄存器会挂死总线」。
加了逐次访问追踪之后，pstore 里的实测是：

```
[2.398] ufs-sprd: sprd,ufs-anlg-syscon resolved via vendor property phy_sram_ext_ld_done
[2.514] ufs-anlg: write reg=0xc bits=0x2 val=0x2
[2.527] ufs-anlg: write reg=0xc done
[2.540] ufs-anlg: write reg=0xc bits=0x4 val=0x4
[2.550] ufs-anlg: write reg=0xc done
[2.662] ufs-anlg: read  reg=0xc ...
[2.666] ufs-anlg: read  reg=0xc = 0x7      ← bit0 = 1，PHY SRAM 初始化完成
[2.804] ufs-anlg: write reg=0xc bits=0x2 val=0x0
```

**读写全部成功。`0x7` 说明 SRAM 已经就绪，PHY 初始化走通了。**

也就是说：UFS 很可能**已经能工作**，只是从来没机会看到结果 ——
每次都在别的地方翻车（init 脚本、USB 链路、BCB）。

### 一个思路陷阱：网络连不上 ≠ 内核挂了

排查过程中反复把「telnet 连不上」当成「内核挂死」，实际原因有三个，
没有一个跟内核有关：

1. **init 会 `switch_root` 到 Ubuntu** —— 切走之后 ramdisk 里的 telnetd
   永远不会执行，而 Ubuntu 那边是 SSH（22 端口）
2. **USB 链路不稳** —— 用户重新插拔一次就好了
3. **`ping 通` 是假象** —— PC 侧静态 IP 丢失后，ICMP 被路由到 WLAN 默认
   网关、被别的设备应答

**可靠判据**：`Get-NetAdapter` 里 `UsbNcm Host Device` 是否存在，
以及拿到的是 `192.168.77.4`（正常）还是 `169.254.x`（DHCP 没起来）。
**最可靠的是屏幕** —— 它不会骗人。

真正的判据是 pstore：有一次日志显示内核连续跑了 **559 秒**才被手动重启，
而当时我这边一直以为它"挂了"。

### ⚠️ 事故：改 BCB 导致黑屏，被迫拆机断电池

**起因**：误判 B 槽被 LK 标记不可用，手工重写了 misc 里的 A/B 元数据。

**错误的写法**（我写的）：

```
slot A = 0xf7 → priority 7,  tries 7, successful_boot = 1
slot B = 0xff → priority 15, tries 7, successful_boot = 1   ← 致命
```

`successful_boot = 1` 让 LK 认为 B 槽已验证可信，**不再消耗 tries、失败也不回退**
→ 无限重启 B 槽 → 屏幕全黑、长按电源无反应。

**正确的写法**（项目原本的 `cx-bcb.bin`，一直是对的）：

```
slot A = 0xfe → priority 14, tries 7, successful_boot = 1
slot B = 0x2f → priority 15, tries 2, successful_boot = 0
CRC    = 0x5415751c
```

B 优先级高于 A（15 > 14）所以优先尝试，但 `successful_boot=0` + `tries=2`
意味着试两次失败就自动回退 A。**已存为 `work/cx-bcb-good.bin`。**

**恢复过程**：黑屏后 USB 完全无枚举 → 拆机断开电池 → 重新进入 EDL
（`SPRD U2S Diag (COM6)`，VID_1782 PID_4D00）→ 用「肥猫小助手」的
「刷入其他分区 → 自定义更多分区」写回 `misc.bin`。

**教训**：不要自己构造 A/B 元数据。项目里已有的那个是对的，直接用。

### 另一个自己挖的坑

改 init 时把调试分支放在了 `mount --move /dev /newroot/dev` **之后**，
导致 init 失去 `/proc` `/sys` `/dev`，后续命令全部 127 →
`Kernel panic - not syncing: Attempted to kill init! exitcode=0x00007f00`。

修法：调试分支必须放在 `mount --move` **之前**，或者直接 `exec /bin/sh`。

---

## 三、方法论（从这两件事里总结的）

1. **「驱动不 probe」有至少四种完全不同的原因**：模块没加载、
   power domain 没注册、compatible 不匹配、component match 卡住。
   表现都是"没有日志"，但修法完全不同 —— 必须先确定它在哪一步停下。

2. **对「看起来同源」的代码要逐项核对，不能靠类比**。
   UFS 的 compatible、时钟、门控、属性名，每一个都是独立的坑。

3. **连接性不是证据**。判断系统状态要用 pstore、屏幕、或本地可验证的判据，
   不要用「能不能连上」倒推「有没有挂」。

4. **修改启动相关的东西（BCB/misc）风险极高**，一旦写错会让设备无法启动
   且无法自行恢复，必须留好回退手段。

5. **先确认硬件到底该不该碰**。这块板的真实存储是 UFS，DT 里也有 UFS 节点，
   但过程中一度被 eMMC 的报错误导过。

---

## 附：当前已知可用状态

| 子系统 | 状态 |
|---|---|
| 显示 | ✅ 480x854，fbcon，背光可调 |
| USB 网络 | ✅ usb0 / NCM |
| 热区 | ✅ 4 个 thermal zone |
| I2C / SPI | ✅ 有设备节点 |
| GPIO 按键 / 耳机检测 | ✅ |
| 音频 | ❌ `hw_ptr` 冻结（另见 `AUDIO-STATUS-2026-10-27.md`） |
| UFS | ❌ `-EIO`，但 PHY 初始化已验证走通 |
| 触控 | ❌ 6.18 树里没有驱动 |
| 电池 / 充电 | ❌ 无 power_supply |
| WiFi / 蓝牙 | ❌ 无 |
