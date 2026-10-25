# 畅行 60 OpenWrt 通话：可修复性复核

日期：2026-10-25。范围：本地代码、HAL 二进制、既有排查记录及公开驱动源码。**本轮没有连接手机、拨号、刷机或修改设备配置，也没有完成通话修复。**

## 判断

现有证据支持“当前实现尚未打通音频”，不足以支持“用户态已经穷尽，只剩厂商文档或 DSP 调试器”。存在可以复现、可以继续检验的路径；能否最终恢复本机听筒、麦克风和喇叭，需要设备实验。

复核输入：`docs/HAL-REVERSE.md`、`.workbuddy/memory/2026-10-25.md`、音频启动/路由/通话脚本、现有内核补丁、`work/hal/whale.so`。保留原有未提交修改，另建本报告，避免覆盖历史记录。

## 1. DSP dump 的 ioctl 已有公开源码

本项目 `tools/build-audio-54.sh` 指定 realme C51/C53 的音频驱动，commit `4381465ccaf87fcf3215b9cd42f4a685df40e5e0`。

已读取该固定版本的 `audio_dsp_dump.c`，与 mu300-audio 保存的 5.4 源文件全文一致。其中 `audio_dsp_ioctl()` 明确实现日志、PCM 转储、内存日志及通话信息控制。对应 ZTE 5.4 内核的 UAPI 头文件列出了命令定义。

- [固定版本驱动实现](https://github.com/realme-kernel-opensource/realme_C51_C53_Narzo-N53-AndroidT-kernel-source/blob/4381465ccaf87fcf3215b9cd42f4a685df40e5e0/kernel_modules/kernel5.4/audio_driver/sprd_audio/audiodspdump/audio_dsp_dump.c#L530)
- [ZTE 内核 ioctl 头文件](https://github.com/dikeckaan/zte-ums9620-kernel-5.4.254/blob/main/include/uapi/sound/sprd_audiodsp_ioctl.h)

因此，“这些协议尚未逆向，所以没有观测手段”需要更正为“这些公开接口尚未在本机按正确 ABI 验证”。**公开接口不等于已验证可用，也不等于完整 DSP 调试器。**

重要细节：多个命令虽然用 `_IOW(..., int)` 定义，处理函数实际直接使用 `(u32)arg`，而非统一从用户指针取值。调用必须逐项对照实现。不能盲目把所有参数都传成指向整数的指针。日志开关、内存转储使能、触发转储是不同操作；不应为了试接口触发 DSP assert。

## 2. major 差 1 不能证明少了 PCM 设备

同一个 dump 驱动在 probe 中使用 `alloc_chrdev_region()`，动态分配字符设备号。加载/探测顺序及其他已注册设备都会影响结果。Android 的 476–479 与 Linux 的 475–478 不能单独证明缺失了某个音频设备，更不能直接解释 ALSA PCM 编号偏移。

[动态分配位置](https://github.com/realme-kernel-opensource/realme_C51_C53_Narzo-N53-AndroidT-kernel-source/blob/4381465ccaf87fcf3215b9cd42f4a685df40e5e0/kernel_modules/kernel5.4/audio_driver/sprd_audio/audiodspdump/audio_dsp_dump.c#L999)。PCM 应按名字、方向、DAI link 和实际节点单独核对。这里不否认两系统确有设备集合差异，只是否定用 major 数字作证明。

## 3. 本机 HAL 会运行时查 PCM，静态表不是最终映射

已运行原有 `tools/hal-pcm-table.py`，确认静态表偏移 `0x77018`、23 项，以及 `FE_ST_VOICE=4` 等提取结果。**提取本身正确；“HAL 必然全部指错”的推论不成立。**

对同一份 ELF32 ARM/Thumb 二进制重新反汇编，发现：

- `audio_utils_get_pcm_device`，函数地址 `0x64560`，打开 `/proc/asound/pcm`，逐行解析、按名称比较并返回实际设备号。
- `platform_set_pcm_id` 在 `0x62194` 调用该查询；`0x621a4` 把返回值写入运行时的用例/方向映射。
- 后续代码按 `0x68` 步长匹配静态 FE 名字，在 `0x621d4` 读取表内的逻辑 ID，并在 `0x621de` 写入另一张映射。
- `platform_get_pcm_id` 从运行时映射取值。

这证明 HAL 存在按名字适配实际 PCM 编号的机制。尚未复现完整 HAL 初始化路径，不能反过来保证所有用例都会正确初始化。不能仅修改静态表或强行让编号相等就宣布修复。

二进制 SHA-256：`48d5d523c16e4119e108cf44d35a3d8cd802b09238c5607b95c7c929909cf650`。

复现命令（只读本地文件，需 capstone）：

```powershell
python tools/hal-pcm-runtime-audit.py work/hal/whale.so
```

## 4. audio_pipe_voice 是定长消息接口，不能用普通文件方式判死

本项目固定版本的 `audio-pipe.c` 中，`open()` 已执行 `aud_ipc_ch_open()`；`read()` 要求长度恰好为 `sizeof(struct aud_smsg)`。此结构是两个 u16 加四个 u32，即 20 字节，内容是通知消息而非音频样本。

源码未显示读取这些消息必须先执行一个未知“初始化 ioctl”。`AUDIO_PIPE_WAKEUP` 调用的是通道唤醒操作，不能把名称理解为“启动 DSP 音频”。

[固定版本源码](https://github.com/realme-kernel-opensource/realme_C51_C53_Narzo-N53-AndroidT-kernel-source/blob/4381465ccaf87fcf3215b9cd42f4a685df40e5e0/kernel_modules/kernel5.4/audio_driver/sprd_audio/audiopipe/audio-pipe.c#L176)。按这份实现，成功读取返回 20，错误走负错误码；既有记录的“返回 0 字节”应核对实际 syscall、读取长度、超时包装、节点类型、已加载模块以及是否有其他读取者，不能直接归因为缺 ioctl。

## 5. DMA 停住是重要线索，但还不是根因证明

既有记录的地址停在 `0xaf725280`、持续 EIO，说明被测路径确有停滞。把它解释成背压可以作为假设，尚不能唯一证明“DSP 永远不读 AP 数据、其他层全正常”。记录也同时出现 NORMAL_AP01 不经 MCDT、以及按 MCDT FIFO 满来归因的说法，需先统一实际测试路径。

尤其要区分：

- NORMAL_AP01 播放测试；
- FE_ST_VOICE 的通话场景；
- AP 注入/采集通话音频的 PCM；
- 本机 codec、听筒、麦克风、功放的路由。

仓库自身的 period-timer 补丁也明确区分无 AP DMA 的 hostless voice 场景。普通播放失败不能独自证明全部通话路径失败。

## 6. 同平台已有进展，但不能直接套用

mu300-audio 项目报告在 F50、OpenWrt、5.4 内核上测得向通话注入音频、录下行和回声。2026-10-19 的维护者回复又确认，通话中的采集周期配置会影响采样率。这说明同平台并非原则上做不到。

- [项目实测范围](https://github.com/dikeckaan/mu300-audio#status)
- [维护者 2026-10-19 实测](https://github.com/dikeckaan/mu300-linux/issues/331#issuecomment-6259196421)

F50 的 DSP 镜像、内核构建和输出方式不等同于畅行 60；AP 音频实测也不代表本机听筒和麦克风已打通。不得直接安装另一设备的内核模块或写入其固件分区。

## 建议的下一轮：先建立可靠判据

1. 明确正在运行的内核、音频模块、节点所属驱动；按 PCM 名称及方向选设备。先验证 20 字节语音通知读取与公开日志接口，在可正常通话的 Android 上建立对照。
2. 对比同一次真实通话中 Android 与 Linux 的初始化时序、profile 参数、上下行 PCM 启动及通知，而非只比较音乐播放或空闲 mixer 快照。
3. 首先证明通话音频能从 AP 采出/注入，再定位本机模拟路由。分别记录实际传输字节、持续时间、非零音频及清理结果；播放状态 RUNNING 或 mixer 写入成功均不能替代音频证据。

在这几项完成前，不给成功率或工期承诺，也不认定已经无路可走。
