# 参考项目：`dikeckaan/mu300-audio`（同平台通话音频）

2026-10-25 整理。**这不是本项目的代码**，是从同平台（ZTE F50 / MU300，Unisoc T760/UMS9620，
OpenWrt + 5.4 内核）的开源项目里摘出来的参考资料。它的硬件和我们的畅行 60 不同（F50 是随身热点，
没有喇叭、没有触摸屏），但它把 Unisoc 音频栈在这条 Linux 路上的边界摸得很清楚——包括哪些做到了、
哪些没做到、卡在哪。

原件：
- <https://github.com/dikeckaan/mu300-audio>
- <https://github.com/dikeckaan/mu300-linux>（`docs/FINDINGS.md`，1.2 MB）

## 文件

| 文件 | 是什么 |
|---|---|
| `mu300-FINDINGS-audio.md` | `mu300-linux` 的 FINDINGS.md 第 24 节全文（24 / 24b / 24c / 24d / 24e），75 KB，全部音频实测记录 |
| `mu300-audio-README.md` | 项目说明：装什么、怎么用、怎么排错 |
| `mu300-audio-dsp` | 管声卡和 DSP 的脚本：加载 23 个模块、写 AGDSP 镜像（分块）、start/stop、开路由 |
| `mu300-voice` | 通话跟随脚本：开场景、配 profile、注入音频（`tone`）、录下行（`echo`） |
| `audio-pipe.c` | `/dev/audio_pipe_*` 的驱动源码（20 字节 `aud_smsg` 消息通道） |
| `audio_dsp_dump.c` | `/dev/audio_dsp_*` 的驱动源码（DSP 日志/内存/PCM 转储的 ioctl） |

## 对我们直接有用的几条

1. **`agdsp_access_en` 决定 AP 的 DMA 能不能动。** `mu300-voice` 注释原文：
   「Hold the AGDSP power domain ... **It is also what lets the AP DMA move at all**
   (kanoqwq/e5-linux FINDINGS 24.2: without it one burst and a stall)」——正是我们观测到的
   「一次突发后指针卡住」。
2. **IIS 端口要分别给时钟。** `VBC_IIS_MST_SEL_0_TYPE` 只管端口 0（普通播放），
   通话场景在**端口 1**，必须 `VBC_IIS_MST_SEL_1_TYPE = VBC_MASTER_INTERNAL`。
3. **`VBC_VOLUME` 是 DSP 侧音量，要写 `音量+1`**（正常通话 7）。我们的驱动把 max 声明成
   `0xffffffff` 导致 ALSA 认为范围非法、任何写入都 EPERM（已修，见 `kernel/build-audio.sh`）。
4. **profile 走 `Audio Structure Profile Update` 控件**（`request_firmware` 路径），不是 `/dev/vbc_turningN`。
   没有 profile 文件时 DSP 会用内置默认值跑通话。
5. **观测手段**（本机同样可用）：
   - `/proc/asound/<card>/vbc` —— DSP 侧 VBC 寄存器（经 IPC 读，安全）；`echo "<reg> <val>"` 可写，
     **绝不要在 AP 侧直接映射 DSP 寄存器，会挂总线**
   - `/sys/kernel/debug/regmap/spi4.0/registers` —— PMIC codec 寄存器，
     `dd bs=15 skip=$((reg/4)) count=1` 读单个（`0x100`=时钟使能，`0x144`=DAC FIFO 状态）

## 他们的天花板（也是我们的）

`24b` 原文：codec 上电、时钟正常、DAC 使能，但 **DAC FIFO 空、写指针停在 0（`0x144 = 0x80`），
没有任何数据通过 AUDIF 从数字 codec 送过来**。

他们能出声的只有两条：
- 蓝牙耳机（由 BT 控制器的 PCM 给 IIS3 提供时钟）
- AP 侧对通话的注入/录制（走 DSP，**不经过本地 codec**）

**用手机自己的喇叭/听筒/麦克风通话，这个项目也没做到。** 这是同平台开源移植的共同边界，
不是畅行 60 独有。

## 不要照搬的部分

- 不要装他们的内核模块或写入他们的 AGDSP 镜像 —— 镜像和模块都是针对 F50 那块板子的具体地址构建的，
  换板子可能直接把设备搞挂（他们的 README 明确写了这条）。
- 他们的 `mu300-voice` 依赖 `mu300-linux` 的目录结构和 `pcmhost`/`ctlset` 工具，不能直接拿来跑。
  可参考的是**配置序列和寄存器观测方法**，不是脚本本身。
