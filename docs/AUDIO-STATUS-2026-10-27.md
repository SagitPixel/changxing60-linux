# 音频现状报告 — 2026-10-27

给外部评审用的完整状态：做到哪、试过什么、排除了什么、卡在哪。

机器：畅行 60（UMS9620 / 展锐 T7520），内核 6.18.54（主线 + 厂商驱动移植）。
提交：`67c7d6b audio: 打开 DSP 载荷、补两处缺失的调用、把 profile 固件装进 ramdisk`

---

## 一、一句话现状

**声卡能注册、PCM 能 open、DAPM 全链路能点亮、DSP 能收到全部命令并逐条应答，
但 VBC 播放 FIFO 只被写入不被读取，`hw_ptr` 冻结，`write()` 返回 EIO。**

---

## 二、硬件/软件拓扑（已确认的部分）

```
应用 aplay
  → ALSA / ASoC
    → FE DAI: FE_DAI_ID_NORMAL_AP01        (sprd-pcm-audio, platform/dmaengine_pcm)
      → DPCM crossbar 开关 S_NORMAL_AP01_P_CODEC (默认 off！)
      → BE DAI: BE_DAI_ID_NORMAL_AP01_CODEC (VBC, dai/vbc_v4)
        → VBC 播放 FIFO (wptr/rptr, 深度约 256)
        → AGDSP / DSP 取数
        → VBC → codec DAC → AO Mixer → AO CUR → AO EN → SPK PA → SPK Pin
```

关键寄存器（AP 侧视角，`vbc-phy-v4.h`）：

```
REG_VBC_AUDPLY_FIFO_CTRL  0x20   数据格式等
REG_VBC_AUD_EN            0x2c   BIT(8) AUDPLY_AP_FIFO0_EN, BIT(9) FIFO1_EN
REG_VBC_AUDPLY_FIFO0_STS  0x34   wptr bits0-7, rptr bits10-17,
                                 FULL_R=BIT(19), EMPTY_W=BIT(18)
REG_VBC_AUD_DMA_EN        0x50
```

命令 ID（SIPC，`AMSG_CH_VBC_CTL`）：

```
SND_VBC_DSP_FUNC_STARTUP    = 4   带 620 字节载荷，等待应答
SND_VBC_DSP_FUNC_SHUTDOWN   = 5
SND_VBC_DSP_FUNC_HW_PARAMS  = 6
SND_VBC_DSP_FUNC_HW_TRIGGER = 7   no-wait，value2 = up_down
```

---

## 三、症状（可复现）

```
$ aplay -D hw:0,0 /tmp/t.wav        # 48kHz / 2ch / S16_LE / 5 秒

t1  OPEN      hw_ptr=0    appl_ptr=0
t2  RUNNING   hw_ptr=160  appl_ptr=24160
t3  RUNNING   hw_ptr=160  appl_ptr=24160
t4  RUNNING   hw_ptr=160  appl_ptr=24160
t5  closed
aplay: pcm_write:2178: write error: Input/output error
```

- `hw_ptr` 停在 **160 帧**（= 640 字节）不动
- `appl_ptr` 冲到 24160（整个缓冲填满）
- 约 1.3 秒后 EIO

**EIO 的确切来源**（`sound/core/pcm_lib.c:2025`）：

```c
	if (!tout) {
		pcm_dbg(substream->pcm, "%s timeout (DMA or IRQ trouble?)\n", ...);  // dev_dbg，静默
		err = -EIO;
		break;
	}
```

即 `wait_for_avail()` 等待可用缓冲超时。**不是 copy 回调失败。**

---

## 四、已经排除的（都有实测证据）

| 假设 | 结论 | 证据 |
|---|---|---|
| crossbar 开关没开导致 open 失败 | **已修正** | `S_NORMAL_AP01_P_CODEC SWITCH` 默认 off，所有 PCM `open` 返回 EINVAL；设为 on 后 open/hw_params/prepare 全过 |
| 输出通路没上电 | **排除** | AO/SPK 路由配置后 DAPM 全链 On：`Normal-Playback` / `DAC` / `Digital Power` / `CLK_DAC` / `AO EN` / `SPK PA` / `SPK Pin` |
| 周期定时器没跑 | **排除** | `period_timer=Y`，实测 10~20 次 hrtimer 回调/播放，`tick_ns=125000000`（6000 帧 @48k） |
| DMA 没提交 | **排除** | `pcm Start branch=SUBMIT`，两通道 `cookie=0x2`、描述符就绪 |
| DMA 地址读数不可信 | **排除** | `sprd_dma_tx_status()` 命中 **current 分支**，`residue_is_addr=1`，residue 就是硬件地址 |
| agdsp 不可访问 | **排除** | 无 "AGCP not accessible" 日志；`agdsp_can_access()` 返回真 |
| FIFO/DMA 没使能 | **排除** | 播放时 `aud_en=0x300`（两个播放 FIFO 都使能）、`dma_en=0x3` |
| IIS 主从配错 | **排除** | `VBC_IIS_MASTER_ENALBE=disable`、`MST_SEL_*=VBC_MASTER_EXTERNAL`，与原厂快照一致 |
| `is_started` 为假导致 trigger 被跳过 | **排除** | 日志 `is_startup=true`，`ap_trigger`/`dsp_trigger` 都执行 |
| DSP 没收到启动命令 | **排除** | SIPC 序列 4→6→7→5，逐条 `ret-value:0` |
| 两个时钟门控没开是原因 | **排除** | `audcp-vbc-ap-eb`/`audcp-aud-ap-eb` 在整棵树里**零消费者**，厂商 DT 也无 clocks 引用，`CLK_IGNORE_UNUSED` 保持关闭是设计行为 |
| profile 固件缺失 | **已修正但仍不够** | 见下 |

---

## 五、本轮修掉的三个真实缺陷

### 1. ramdisk 里完全没有 DSP profile 固件

`vbc_profile_loading()` 用 `request_firmware()` 加载：

```c
static const char * const sprd_profile_name[] = {
	"audio_structure", "dsp_vbc", "cvs", "dsp_smartamp",
};
```

**原 ramdisk 连 `/lib/firmware` 目录都没有。** 而且加载是由 mixer 控件触发的
（`Audio Structure Profile Update` / `DSP VBC Profile Update` / `CVS Profile Update`），
实测初始值全是 0 —— 从未加载过。

已修：`boot/make-618-image.sh` 把 `work/firmware/` 下的三个装进 `/lib/firmware/`：

```
lib/firmware/audio_structure   48934
lib/firmware/cvs               55500
lib/firmware/dsp_vbc          124728
```

实测 `vbc_profile_loading: cvs ... return 0`，控件读回 1。

**遗留**：加载仍靠手工 `amixer` 触发，**还没写进 `/init`**；`dsp_smartamp` 我们没有。

### 2. `scene_normal_hw_params()` 从不调 `dsp_hw_params()`

四个调用点：

```
scene_capture_dsp_hw_params        ✅
scene_recognise_capture_startup    ✅
scene_fast_hw_params               ✅
scene_offload_hw_params            ✅
scene_normal_hw_params             ❌  ← 唯一缺失
```

后果：**cmd=6 HW_PARAMS 从来没发给 DSP**，而 startup 的 620 字节载荷里
（`struct snd_pcm_startup_paras`）**没有 rate/format/channels 字段**。

已修后 SIPC 序列：

```
cmd=4 STARTUP     ret=0
cmd=6 HW_PARAMS   ret=0     ← 新增
cmd=7 HW_TRIGGER
cmd=5 SHUTDOWN
```

### 3. startup 载荷里 `dac_out[]` 全为 0

`VBC_MUX_DAC0_OUT_SEL` 默认 `DAC_OUT_FROM_IIS`（枚举只有 IIS / VBCIF 两项），
导致 `fill_dsp_startup_data()` 填出的 `dac_out[]` 全零，DSP 拿不到 DAC 输出目标。

改成 `DAC_OUT_FROM_VBCIF` 后载荷出现 `dac_out[0] id=0 val=1`。

**这条只有推理支撑**：`work/calldump.txt` 是通话场景，那里确实是 `DAC_OUT_FROM_IIS`；
通话走 IIS 合理，但播放数据是从 VBC FIFO 来的。**尚未被证实。**

---

## 六、可用的诊断（都已实现并验证）

### A. `sprd-audio-diag/snapshot`（PCM 侧，安全）

```
$ cat /sys/kernel/debug/sprd-audio-diag/snapshot
target=sprd,ums9620-audcpglb-gate off=0x4 mask=0xa0000 read_hw=0
play_seq=3 stopped=0 total=8
<ns> play=3 smp=7 pm_ret=0 access_ok=1 read_done=1 read_ret=0 gate_raw=0x00000000 \
     vbc_ap_eb=0 aud_ap_eb=0 state=3 hw_ptr=0   appl_ptr=24000
<ns> play=3 smp=8 pm_ret=0 access_ok=1 read_done=1 read_ret=0 gate_raw=0x00000000 \
     vbc_ap_eb=0 aud_ap_eb=0 state=3 hw_ptr=160 appl_ptr=24160
```

设计要点（这几条是踩过坑才定下来的）：

- 采集在 **delayed work（进程上下文）**，不在 trigger/pointer/hrtimer 的自旋锁里
- 采集时**额外**取 `pm_runtime_resume_and_get()`，读完 `pm_runtime_put_autosuspend()`
- 失败就记 `pm_ret` 并跳过硬件访问，不绕过保护
- 只在**成功的 START/RESUME/PAUSE_RELEASE** 后 arm；
  STOP/SUSPEND/PAUSE_PUSH 在**分支入口**非阻塞撤权（该分支有 early return）
- `hw_free/close` 里 `cancel_delayed_work_sync()`，无流锁
- debugfs 读的是**内存快照**，锁内 memcpy、锁外格式化，不碰 MMIO
- 硬件读由 `diag_read_hw` 模块参数控制（默认 N）

### B. `dsp_startup` 载荷 dump

`dsp_startup()` 里 `fill_dsp_startup_data()` 之后，打印 620 字节 hex（32 字节/行）
+ 各数组非零项。实测关键偏移：

```
0x000-0x01f  stream_info.name[32]  = 全 0
0x020        stream_info.id        = 0   (NORMAL_AP01)
0x024        stream_info.stream    = 0   (playback)
0x028        dac_id                = 0   (VBC_DA0)
0x02c        adc_id                = 0
0x034 起     dac_out[]             = (id 0, val 1) 改 VBCIF 后
```

`stream_info.name` 全零不是 bug：`dsp_startup`/`shutdown`/`hw_params`/`hifi` 四处
**一致都不填 name**，说明 DSP 不用它。

### C. `sprd-dma-diag/tx_status`

`sprd_dma_tx_status()` 的四个分支各记一条（complete / queued / current / unmatched），
含 chan_id、cookie、status、pos、`residue_is_addr`。固定 16 条环形缓冲 + 自旋锁。

实测全部命中 `current`，所以读到的 `pos` 确实来自正在执行的描述符。

### D. `clk-audcp-diag/identity`

只输出 audcpglb 时钟 provider 的身份（dev 名 / DT 路径 / compatible / 资源范围 /
目标偏移），**不读任何寄存器**。

---

## 七、已移除的东西（重要教训）

`vbc-diag/fifo` 曾经用来直读 FIFO 寄存器，**已整个删掉**：

```
Comm: cat
pc : ap_vbc_reg_read+0x2c [snd_soc_sprd_vbc_v4]
lr : vbc_fifo_show+0x48   [snd_soc_sprd_vbc_v4]
SError Interrupt -> Kernel panic
```

原因：`agdsp_can_access()` 检查与 `ap_vbc_reg_read()` 之间没有保护，
**播放启停的过渡期**会出现「检查通过、读取时域已切换」→ 同步外部中止。

同一个坑在 `ums9620-clk.c` 上也踩过一次（无保护的 `regmap_read(0x4)`）。

**结论：AGCP 域内寄存器不能从 debugfs 直读。**
需要采样就走「工作队列 + PM 引用 + 访问检查 + 内存快照」那条路。

---

## 八、卡在哪（精确描述）

### 实测的 FIFO 状态（拆除 debugfs 前采集）

```
空闲:  wptr=0   rptr=0   empty_w=1
播放:  wptr=161 rptr=9   full_r=0  empty_w=0
1 秒后: wptr=161 rptr=9   ← 完全不动
```

**写侧通了（DMA 确实写进 161 个），读侧只读了 9 个就停了。**

### 同一时间的 DMA

```
16 次采样，跨度 1.1 秒：
chan=0 cookie=2 status=1 branch=current pos=0xaf725280 residue_is_addr=1
chan=1 cookie=2 status=1 branch=current pos=0xaf725282 residue_is_addr=1
```

地址一个字节都不动。`status=1` 是 `DMA_IN_PROGRESS`。

### 送进 DSP 的东西

```
命令：4 STARTUP(620B) → 6 HW_PARAMS → 7 HW_TRIGGER(up=1)   全部 ret=0
载荷：scenario/id/stream/dac_id 正确，dac_out 已填
固件：audio_structure / cvs / dsp_vbc 已在共享内存（vbc_profile_loading return 0）
```

### 所以卡点

**DSP 收到全部命令、参数、固件，逐条应答成功，但就是不开始从播放 FIFO 取数。**

`vbc_profile_loading()` 只是把固件 `unalign_memcpy` 到共享内存（打印了 `virt_to_phys`），
然后 `release_firmware()` 返回，**没有向 DSP 发任何 SIPC 通知**。
DSP 是轮询 `p_profile_setting->is_loading[]` 还是靠别的机制发现固件，主机侧无从得知。

---

## 九、开放假设（按可能性排序，供新方案参考）

1. **DSP 侧还有独立于命令的启动条件没满足**
   比如 DSP 自己的采样时钟 / PLL、内存域、或某个 AP 从不触碰的控制位。
   主机侧已经看不到，需要有 DSP 侧状态寄存器或固件日志才能继续。

2. **profile 加载后缺少通知/握手**
   `vbc_profile_loading()` 写完共享内存就返回了。若 DSP 期望一条 SIPC 命令
   或某个 doorbell，那这条没发。

3. **`dac_out` 的正确值其实不是 VBCIF**
   我改 VBCIF 是推理。如果原厂 AP01 播放其实也用 IIS（`DAC_OUT_FROM_IIS`），
   那 DSP 的取数路径可能根本不经过 AP FIFO —— 但这与「DMA 能写进 161 个」
   矛盾，除非写入是 DMA 侧的独立行为。

4. **DSP 固件版本与 AP 驱动协议不匹配**
   我们用的是从本机 Android 分区提取的固件，但驱动是 M8/E5 移植过来的。
   若 `struct snd_pcm_startup_paras` 布局与固件期望的不一致，DSP 会解析出乱码
   并静默不动 —— 620 字节长度对上了，但字段偏移没验证过。

5. **上游"消费端"被别的东西堵住**
   DSP 内部缓冲 → VBC 输出 → codec。如果 codec 侧不接收（时钟/接口方向问题），
   DSP 填满内部缓冲后就会停 —— 这最符合「读 9 个就停」的形态。

---

## 十、给新方案的建议

**最有信息量的一步**（我做不到但值得尝试）：

- 拿到 DSP 侧的运行状态。哪怕是原厂 5.4 上**同一次 AP01 播放**的完整 dmesg，
  对比 SIPC 序列和寄存器快照，也能立刻看出少了哪一步。
  现有 `work/calldump.txt` 是**通话**场景，不是播放，不能当基线。

**次优**：

- 用 AP23 播放（`FE_ST_NORMAL_AP23`）做对照。如果 AP23 能出声，说明是 AP01
  这条场景的配置问题；如果同样卡住，说明是更底层（DSP/时钟/固件协议）。
  这条路只需要改 crossbar 开关和 PCM 设备号，不需要新代码。

**如果拿到 DSP 固件的协议头**：

- 逐个字段核对 `struct snd_pcm_startup_paras` 的偏移与固件期望是否一致。
  620 字节总长对上只说明长度对，不说明布局对。

---

## 十一、工程约束（避免重复踩坑）

1. **AGCP 域内寄存器不能从 debugfs 直读** —— 会 SError panic。需要采样走工作队列。
2. **不要在 trigger/pointer/hrtimer 的自旋锁上下文里做会睡眠的事**（SIPC、regmap、PM）。
3. **模块引用内建内核的 `EXPORT_SYMBOL_GPL` 符号时**，打包必须用**加导出之后**编译的
   Image；否则模块报 `Unknown symbol` 加载失败，声卡整个起不来。
4. **`vbc-diag` 之类的直读接口删了别再随手加回来**。
5. 判断 DSP 是否在消费，看 `hw_ptr` 和 aplay 退出码就够了，不需要读硬件。
