# 逆向 `audio.primary.whale.so`（Android 音频 HAL）

2026-10-25。目标：找出 Android 的音频 HAL 在用户态做了什么是我们 Linux 这边没做的。

> 后续复核：本文保留历史记录；其中 major 偏移、静态 PCM 编号以及“用户态已补齐、DSP 无观测手段”的结论不再作为定论。
> 见[源码复核](VOICE-FEASIBILITY-REVIEW-2026-10-25.md)和[设备实测](VOICE-DEVICE-ROUND-2026-10-25.md)：已读出 DSP 数据、点亮通话 codec，并修复缺包和主麦路由；实际通话仍双向无声。
> 2026-10-26：[本机听筒基线与 M8 对照](7552N-M8-AUDIO-COMPARISON-2026-10-26.md)发现 AO/Receiver 与内部 IIS 路由差异；临时验证已建立原厂形态的上电路径，但用户试听仍双向无声，尚未修复。

## 怎么拿到的

```sh
adb shell su -c 'cp /vendor/lib/hw/audio.primary.whale.so /sdcard/whale.so'
adb pull /sdcard/whale.so
```

`ro.hardware` = `ums9620_2h10`，但真正加载的是 `/vendor/lib/hw/audio.primary.whale.so`
（541272 字节，**ELF32 / ARM**，带符号名，未 stripped）。

`/vendor/lib64/hw/audio.primary.default.so` 是 AOSP 的空壳（11416 字节，"Default audio HW HAL"），
不是厂商实现 —— 别再被它误导。

## 关键发现 1：AGDSP 由 HAL 在用户态启停

```
/sys/devices/platform/audiocp_boot/start
/sys/devices/platform/audiocp_boot/stop
"start dsp now"
```

HAL 里**没有任何 DSP 固件的文件名**（唯一的 `.bin` 是 `awinic_params.bin`），
说明镜像不是 HAL 从文件加载的，HAL 只负责 start/stop。

实测：仅 `echo 1 > .../start` 不足以让 DSP 开始消费音频（DMA 仍停在 640 字节）。

## 关键发现 2：PCM 设备表（已完整提取）

HAL 内有一张 `name → ALSA device` 表，条目结构为 `char name[100]; int device;`（步长 0x68），
文件偏移 `0x077018` 起：

| device | 名字 | device | 名字 |
|---:|---|---:|---|
| 0 | FE_ST_NORMAL_AP01 | 9 | FE_ST_LOOP |
| 1 | FE_ST_NORMAL_AP23 | 10 | FE_ST_A2DP_PCM |
| 2 | FE_ST_CAPTURE_DSP | 11 | FE_ST_CAPTURE_FM_DSP |
| 3 | FE_ST_FAST | 12 | FE_ST_CAPTURE_BTSCO_DSP |
| 4 | FE_ST_VOICE | 13 | FE_ST_FM_DSP |
| 5 | FE_ST_VOIP | 14 | FE_ST_DUMP |
| 6 | FE_ST_FM | 16 | FE_ST_TEST_CODEC |
| 7 | FE_ST_FM_C | 17 | FE_ST_VOICE_PCM_P |
| 8 | FE_ST_VOICE_C | 18/19 | FE_ST_HIFI_P / HIFI_FAST_P |

提取脚本见 `tools/hal-pcm-table.py`。

## 关键发现 3：我们内核的 PCM 编号和厂商不一致（真 bug）

本机 `/proc/asound/pcm` 实际是：

```
00-00 FE_ST_NORMAL_AP01   00-05 FE_ST_VOICE    ← HAL 期望 4
00-01 FE_ST_NORMAL_AP23   00-06 FE_ST_VOIP     ← HAL 期望 5
00-02 FE_ST_CAPTURE_DSP   00-09 FE_ST_VOICE_C  ← HAL 期望 8
00-03 FE_ST_FAST          00-10 FE_ST_LOOP     ← HAL 期望 9
                          00-12 FE_ST_A2DP_PCM ← HAL 期望 10
```

**从 FE_ST_VOICE 起整体 +1（后面 +2），中间缺 device 4。**
说明内核的 dai_link 枚举顺序 / 数量与厂商不同 —— 有一个 FE 的 PCM 没注册成功。
目前用 aplay 直接指定 `hw:0,5` 是自洽的，所以不影响我们的测试；
但如果哪天跑 Android 的 HAL，它的设备表会全部指错。

## 关键发现 4：通话走独立的 UL / DL 双 PCM

```
voice open pcm_open start ul pcm device:%d config rate:%d channels:%d format:%d
voice open pcm_open start dl pcm device:%d config rate:%d channels:%d format:%d
start voice_rx VOICE_UL_CAPTURE_UPLINK
start voice_rx VOICE_UL_CAPTURE_DOWNLINK
```

即通话时 HAL 分别打开上行和下行两个 PCM，而不是单一 hostless 设备。

## 尚未解释的

- DSP 应答 SIPC 命令，但完全不读 `audio-mem`（DMA 写入 640 字节后因背压停摆）
- 所有 `audcp-*` 时钟在播放时仍为 0（仅 `audcp-dma-ap-eb=1`）
- `NORMAL_AP01` 路径不经过 MCDT（播放时无任何 mcdt 日志），DMA 直接写 `audio-mem`

## 关键发现 5：HAL 用到的全部内核接口（从字符串提取）

```
/dev/audio_dsp_log  /dev/audio_dsp_mem  /dev/audio_dsp_pcm  /dev/audio_dsp_call_info
/dev/audio_pipe_voice        /dev/audio_pipe_trigger_tx
/dev/pipe/mmi.audio.ctrl
/dev/vbc_turning0  ...  /dev/vbc_turning3        ← 四个，不止三个
/proc/asound/sprdphonesc2730/{vbc,sprd-codec,sprd-dmaengine}
/sys/devices/platform/audiocp_boot/{start,stop}
/sys/class/switch/h2w/state   /sys/kernel/headset/state
```

**`/dev/audio_pipe_voice` 等节点在本机默认不存在**，尽管 `audio_pipe` 模块已经加载。
手动 `modprobe audio_pipe` 之后才出现在 `/dev/` 下 —— 说明这些节点的创建时机有问题
（可能依赖 HAL 的某个动作，而 Linux 没有人做）。

已实测：
- 通话中直接 `read()` `/dev/audio_pipe_voice` → 0 字节（需要 ioctl 配置，不是裸读）
- 节点补齐后通话仍无声音，说明节点存在本身不解决问题

## 结论（2026-10-25）

用户态该做的事已经查清并补齐：profile、路由、增益、省缺节点。
DSP 依然不消费 `audio-mem` 的数据。要再往下，需要 DSP 侧的可观测手段
（`audio_dsp_log` 需要 ioctl 使能，未逆向）或厂商的 DSP 初始化序列文档。

## 工具

- `work/hal/xref2.py`：按 program header 解析 ELF32，用 capstone 找字符串的代码引用
  （注意：该 .so 用字符串拼接构造路径，直接 xref 找不到，需从基路径入手）
- `tools/hal-pcm-table.py`：从 `whale.so` 提取 PCM 设备表
