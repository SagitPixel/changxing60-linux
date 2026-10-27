# 音频现状报告 — 2026-10-27（更新版）

机器：畅行 60（UMS9620 / 展锐 T7520），内核 6.18.54（主线 + 厂商驱动移植）。

**本文档在 2026-10-27 晚重写**：原版本基于「播放走 AP01」的假设，
该假设已被原厂 Android 实测推翻。凡与新证据冲突的旧结论都已重写。

---

## 一、一句话现状

原厂 Android 的媒体播放在本机**实际有声**，走的是 **FAST**（`FE_ST_FAST` /
`VBC_DAI_ID_FAST_P`），不是 AP01。6.18 上已把 FAST 场景及关键配置**逐项对齐原厂**，
仍然 `hw_ptr` 冻结、`write()` 返回 EIO。

---

## 二、硬件/软件拓扑

```
应用 aplay / AudioTrack
  → ALSA / ASoC
    → FE DAI  ：FE_DAI_ID_FAST_P          (sprd-pcm-audio, platform/dmaengine_pcm)
      → DPCM crossbar：S_FAST_P_CODEC SWITCH
      → BE DAI  ：BE_DAI_ID_FAST_P_CODEC  (VBC, dai/vbc_v4)
        → MCDT 逻辑通道 4 → AP DMA → VBC FIFO
        → AGDSP 取数
        → VBC → IIS → DAC → AO/SPK
```

命令 ID（SIPC，`AMSG_CH_VBC_CTL`）：

```
SND_VBC_DSP_FUNC_STARTUP    = 4   带 620 字节载荷，等应答
SND_VBC_DSP_FUNC_SHUTDOWN   = 5
SND_VBC_DSP_FUNC_HW_PARAMS  = 6
SND_VBC_DSP_FUNC_HW_TRIGGER = 7   no-wait，value2 = up_down
```

---

## 三、症状（6.18，FAST 场景）

```
2  OPEN     hw=0    appl=0
3  OPEN     hw=0    appl=0
4  SETUP    hw=0    appl=0
5  RUNNING  hw=360  appl=24000
6  RUNNING  hw=360  appl=24360
   ...后续 RUNNING 样本 hw_ptr 恒为 360
最终：aplay: pcm_write:2178: write error: Input/output error, rc=1
```

实际协商参数（**播放中**抓取，不是结束后）：

```
access:      RW_INTERLEAVED
format:      S16_LE
subformat:   STD
channels:    2
rate:        48000
period_size: 6000
buffer_size: 24000
```

`hw_ptr` 停在 **360 帧 = 单个周期的 6%**。

**EIO 来源**（`sound/core/pcm_lib.c`）：`wait_for_avail()` 等可用缓冲超时，
不是 copy 回调失败。

---

## 四、原厂 Android 媒体播放基线（本轮新增，最重要）

### 采集方法

- Android 13，`cn.zte.music` 的 `AudioPreviewActivity`
- intent 打开播放器后是 **idle**，必须 `cmd media_session dispatch play` 才真正播放
- 5 秒 WAV 来不及抓「播放中」，要用 **30 秒**
- 快照只用软件状态（tinymix / proc/asound / dumpsys / dmesg / logcat），
  **不碰 debugfs regmap**，不新增域内 MMIO

### 确认实际有声

```
AudioPlaybackConfiguration piid:95  type=android.media.AudioTrack
  state:started  usage=USAGE_MEDIA  content=CONTENT_TYPE_MUSIC  deviceId:3

Output thread AudioOut_D: 48000 Hz, HAL format PCM_16_BIT, type 0 (MIXER)
  2 Tracks of which 1 are active
```

### ❗ 关键事实一：走的是 FAST，不是 AP01

```
[71.096] vbc_profile_try_apply: now_mode[1]=1078657024, mode=75, mode_offset=64
[71.113] scene_fast_trigger: dai:BE_DAI_ID_FAST_P_CODEC(3) scene:VBC_DAI_ID_FAST_P playback, cmd=1
```

`FE_ST_FAST` / `VBC_DAI_ID_FAST_P`。**AP01 在这个产品上 HAL 很可能根本不用** ——
这也解释了为什么 `scene_fast_hw_params` 里 `dsp_hw_params` 调用是完整的，
而 `scene_normal_hw_params` 缺（那条路没人走）。

### ❗ 关键事实二：DAC_OUT 是 IIS，不是 VBCIF

```
VBC_MUX_DAC0_OUT_SEL = DAC_OUT_FROM_IIS     （播放中，实际有声）
```

数据路径是 **DSP 读 AP FIFO → 写 IIS → DAC**。
之前把它改成 `DAC_OUT_FROM_VBCIF` 是错误的推断，应还原。

### ❗ 关键事实三：Profile Select 只设一个，且 param_id 非零

| 控件 | 播放中的值 |
|---|---|
| Audio Structure Profile Update | 0 |
| DSP VBC Profile Update | 0 |
| CVS Profile Update | 0 |
| Audio Structure Profile Select | **0** |
| **DSP VBC Profile Select** | **1078657024 = 0x404B0000** |
| NXP Profile Select | **0** |

解码 `0x404B0000`：

```
offset   = 0x40 = 64    → Music / Handsfree / Playback（外放）
param_id = 0x4B = 75
dsp_case = 0
```

**只设 DSP VBC 一个；param_id 是 75 不是 0。**

### 基线文件

`baseline/2026-10-27/android/`：before / during2 两套完整快照
（mixer / pcm / flinger / policy / audio / dmesg / logcat，约 1.2 MB）。

---

## 五、已修的缺陷

### 1. ramdisk 里没有任何 DSP profile 固件

`vbc_profile_loading()` 用 `request_firmware()` 加载
`audio_structure` / `cvs` / `dsp_vbc` / `dsp_smartamp`，
原 ramdisk **连 `/lib/firmware` 都没有**。已加入三个（`dsp_smartamp` 本机没有）。

### 2. Select 控件上限把值截断了（真 bug）

```c
#define VBC_PROFILE_CNT_MAX 0x0fffffff     // 只有 28 位
```

Select 编码是 `(offset << 24) | (param_id << 16) | dsp_case`，
`0x0fffffff` 导致 **offset 最大只能到 15**。音乐播放是 offset 64，
`64<<24 = 0x40000000` 会被 ALSA 核心**静默截断**。

改成 `0x7fffffff` 后实测 `Limits: 0 - 2147483647`，offset 64 可正常写入。

### 3. startup 载荷里 `dac_out[]` 全为 0

`VBC_MUX_DAC0_OUT_SEL` 为 `DAC_OUT_FROM_IIS` 时 `dac_out[]` 才会被填
（干净启动默认就是 IIS，和原厂一致）。用 VBCIF 做的实验应还原。

### 4. `scene_normal_hw_params` 缺 `dsp_hw_params()`

已补。但**这是 AP01 路径，而原厂不走 AP01** —— 该补丁目前作为**独立实验变量**保留，
不算已确认修复。

---

## 六、已排除（有实测依据）

| 假设 | 结论 | 依据 |
|---|---|---|
| 输出通路没上电 | 排除 | DAPM 全链 On |
| 周期定时器没跑 | 排除 | hrtimer 回调正常 |
| DMA 没提交 | 排除 | cookie 3→4，descriptor 就绪 |
| DMA 地址读数不可信 | 排除 | `tx_status` 命中 current 分支 |
| agdsp 不可访问 | 排除 | 无 "AGCP not accessible" |
| FIFO/DMA 没使能 | 排除 | `aud_en=0x300`、`dma_en=0x3` |
| DSP 没收到命令 | 排除 | SIPC 4→6→7→5 全部 ret=0 |
| PCM 场景选错（AP01 vs FAST） | 当前组合下非充分条件 | FAST 同样 EIO |
| DAC_OUT 选错 | 当前组合下非充分条件 | IIS 下同样 EIO |
| Profile Select 值错 | 当前组合下非充分条件 | 0x404B0000 逐位一致仍失败 |
| FAST 上层链路没配好 | 排除 | hw_params 协商出 48k/16bit/2ch |
| MCDT 未使能 | 排除 | `mcdt_dac_dma_enable_r2 channel=4` |
| MCDT 时钟门控挡掉寄存器写 | 排除 | `mcdt clocl not available` 计数 = 0 |

**注意措辞**：场景 / DAC 路由 / profile 三项只能在**当前这份组合**下说
「不是充分条件」，不能宣布整体排除。

---

## 七、可用的诊断

### A. `sprd-audio-diag/snapshot`（PCM 侧，安全）

工作队列 + PM 引用 + `agdsp_can_access()` + 内存快照，
记录 `play_seq / smp / pm_ret / access_ok / read_ret / gate_raw / state / hw_ptr`。
只在成功的 START/RESUME/PAUSE_RELEASE 后采样，STOP 分支入口非阻塞撤权。

### B. `dsp_startup` 载荷 dump

620 字节 hex（32 字节/行）+ 各数组非零项。已解出：
`stream_info.name` 全零（四处一致不填，DSP 不用）、
`dac_out[]` 视 `VBC_MUX_DAC0_OUT_SEL` 而定。

### C. `sprd-dma-diag/tx_status`

记录 `sprd_dma_tx_status()` 走哪个分支（complete / queued / current / unmatched），
含 chan_id / cookie / status / pos / `residue_is_addr`。

### D. `clk-audcp-diag/identity`

只输出时钟 provider 身份，不读寄存器。

### E. profile 发送链日志

```
vbc-profile-select: id / value / offset / pid / dsp_case / max / data
vbc-profile-set:    type / mode / len / ret
vbc-profile-apply:  id / now_mode / mode_offset / ret
```

**这三个是「profile 是否真的发出」的唯一主机侧证据。**

---

## 八、卡在哪（精确描述）

### 现象

- `hw_ptr` 冻结在 360（多个 RUNNING 样本一致）
- DMA `cookie` 递增（提交成功），但 `pos=0xaf7255a0` 两次采样完全相同
- `aplay` 约 1.2 秒后 EIO

### 两个候选方向（表现相同，修法不同）

| 可能 | 判据 |
|---|---|
| DMA 通道没真正启动（`issue_pending` 没生效） | 通道状态寄存器的 ACTIVE 位 |
| MCDT 没向 DMA 发请求（下游不消费，FIFO 满） | MCDT 通道 4 的读写指针 |

### 已核实的相关事实

- MCDT 驱动是 `mcdt_r2p0` 变体（树里只有这一版，不是配置选错）
- 原厂 5.4 调用 `mcdt_dac_dma_enable`，我们调用 `mcdt_dac_dma_enable_r2` —— 版本差异
- MCDT 寄存器写的时钟门控检查**通过**（`mcdt clocl not available` 计数为 0）

---

## 九、开放假设

1. **DMA 通道未真正启动** —— 描述符就绪、cookie 递增，但硬件不跑
2. **MCDT 下游不消费** —— DSP 不取数导致 FIFO 满，DMA 被反压
3. **FAST trigger 之后 DSP 没收到有效启动条件** —— 需 DSP 侧状态确认
4. **r2p0 MCDT 与 5.4 的使能流程差异** —— 版本更新是否引入行为差异

---

## 十、下一步

1. **完整梳理 FAST 的 DMA 映射**（大部分是软件信息，不碰硬件）：
   MCDT compatible / 资源范围 / `sprd,ap-addr-offset`、
   逻辑通道 4 → AP DMA 通道映射、请求 UID、
   fast_p 实际拿到的控制器与通道、源/目的地址、周期、数据宽度、
   submit 返回值 / cookie / issue_pending
2. **区分「DMA 没启动」与「下游不消费」** —— 目前最关键的分叉
3. 若需要硬件采样，**复用已有的安全快照机制**
   （工作队列 + PM + 访问检查 + 内存快照），debugfs 只读内存快照，不直读寄存器

---

## 十一、工程约束（踩过的坑）

1. **AGCP 域内寄存器不能从 debugfs 直读** —— 会 SError panic，已实测两次
2. **不要在 trigger/pointer/hrtimer 的自旋锁上下文里做会睡眠的事**（SIPC、regmap、PM）
3. **模块引用内建内核的 `EXPORT_SYMBOL_GPL` 符号时**，
   打包必须用加导出之后编译的 Image
4. **`boot/module-order-618.txt` 必须保持 LF** —— Windows 上改过会变 CRLF，
   打包报 "30 module(s) missing"
5. **判断 DSP 是否消费用 `hw_ptr` 和 aplay 退出码**，不需要读硬件寄存器
6. **`/sys/class/display/*` 在 DRM 卡注册前写会 NULL deref**（显示侧同类教训）
7. 测量时 `dmesg -c` 的位置要注意 —— 清在写入之后会把发送证据一起清掉

---

## 十二、证据等级说明

| 结论 | 等级 |
|---|---|
| 载荷已送达 DSP | 强（SIPC ret=0） |
| hw_params 已送达 | 强（cmd=6 ret=0） |
| trigger 已发送 | **弱：no-wait，只能说发送返回成功，无应答** |
| profile 已进共享内存 | 中（SHAREMEM_SET ret=0，DSP 是否取用未知） |
| DSP 未取数 | 强（hw_ptr 冻结 + DMA 地址不动） |
| 原厂走 FAST | 强（原厂 dmesg 实测） |
| 原厂 DAC_OUT=IIS | 强（原厂 mixer 播放中快照） |
