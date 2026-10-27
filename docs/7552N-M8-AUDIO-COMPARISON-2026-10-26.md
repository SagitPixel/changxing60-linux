# 7552N 与 M8 音频对照：是否必须迁移 6.18

日期：2026-10-26。范围：当前 7552N 的 5.4.254 内核、已部署用户态音频程序，
以及本地 M8 / e5-6.18 参考树。没有刷机、切槽或替换运行中的模块。

## 结论边界

现有证据不支持“5.4 的 codec DAPM 从未点亮，因此只能迁移”。
此前两轮真实通话仍然双向无声，但记录中播放后端已 start，Normal-Playback、
DAC、Digital Power 已 On；补齐模拟麦克风开关后，录音后端和 ADC 也已 On。
上电、IPC 应答、PCM start 均不能证明音频样本已成功传输。

F50 / mu300 的工作可参考公共 DSP、IIS 和协议行为，但不能证明本机的模拟 codec、
麦克风、听筒、功放路径正确。M8 是更接近的参考机，但仍有板级接线和 DT 差异。

## 原厂普通听筒通话基线

用户明确确认 `work/calldump.txt` 是普通听筒通话，没有开免提。
按控件名称比较这份 Android 快照与第一轮 Linux 通话快照：326 对 319 个控件，
缺少的 7 个均为 AW87xxx 相关控件；排除不能可靠解码的两个 BYTE 值后，共 60 个值不同。
这不支持把“全部 mixer 一致”作为当前运行版本已排除路由问题的证据。

| 项目 | 原厂听筒快照 | 原 Linux 通话程序/快照 |
| --- | --- | --- |
| 逻辑设备 | TYPE_RCV | 未按本机基线明确设置 |
| 物理 codec 输出 | Speaker Function On，AO Mixer AOL/AOR On | Earpiece Function On，EAR_HPL On |
| 功放场景 | Receiver | ALSA 中无对应控件；必须另核对 sysfs |
| IIS0 内部连接 | aud_4ad_iis0_da0 | pad_top |
| IIS1 内部连接 | aud_4ad_iis0_ad0 | pad_top |
| ADC2 输入 | ADC_IN_IIS0_ADC | ADC_IN_IIS1_ADC |
| ADC / ADC1 LRCLK | invert | normal |
| 麦克风选择 | MIC13、主麦与 Aux Mic2 | 路径未完整匹配 |
| DAC 左右交换 | disable | enable |
| DSP profile | 0x02020005 | 默认 NB 0x00000005 |

`Speaker Function` 是驱动端点名，不能据此把逻辑听筒切成免提 DSP profile。
这些设置支持“codec AO 模拟输出经 AW87xxx 到实际发声器件”的工作假设；
没有原理图/器件资料时，不仅凭驱动没有 TDM 设置就宣称所有物理接线已确定。
功放底噪或 profile 能切换也不能证明 DAC 有有效信号。

## 临时原厂路径试验

`tools/audio/trial-native-receiver.py` 只包装已审查版本的通话程序，校验 SHA256，
不替换正式程序，不操作呼叫信令，不打开危险的 FAST/CAPTURE_DSP/VOICE_C PCM。
仍按名称找到 FE_ST_VOICE，使用现有 8 kHz hostless PCM。
它修正上述内部连接、模拟路由和麦克风设置，保留 Handset profile，
在 PCM 启动后重新选择 AW87xxx Receiver，退出时恢复此前全部设置。
WB 参数是依据旧原厂快照选择的试验条件，不代表已解析本次通话的网络协商结果。

无通话启停实测：

- `Normal-Playback`、`DAC` 均 On，in 1 / out 10；Digital Power On。
- `Normal-Capture-AP01`、`ADC` 均 On，in 4 / out 1。
- AW87xxx 从此前 Music 切到 Receiver，停止后恢复 Music。
- 所有 319 个 mixer 值恢复完全一致，PCM5 播放/采集均 closed。

证据：`work/voice-review-20261025/native-receiver-cycle.json`。
真实通话试听结果另记本文件后续章节；仅以上结果不能宣称声音修复。

### 实际来电采集

用户拨入并接听后，协调脚本先停止普通音频实例，再启动临时实例，避免两个进程争读
语音通知管道。获得 32 份快照，uptime 36083.55 至 36148.05，覆盖约 64.5 秒。
全程播放/录音 codec 上电，逻辑听筒、WB profile、AO 及内部 IIS 选择均已应用。
与原厂快照的不同值降至 22 个：主要为未开启的其他场景开关、ADC3/sidetone、
Inter PA Config，以及本次较低的 VBC_VOLUME=2；这仍不是完整等价性证明。

初始启动快照中功放 sysfs 一度显示 Off，不能隐去这个反例。
同时期音频日志记录 DSP 带宽从 NB 切到 WB，切换时会重写功放 profile；
内核在 uptime 36083.550 和 36083.603 明确记录寄存器已是 receiver mode。
随后直到 36150.240 试验退出才出现关功放日志。最合理解释是首次 sysfs 读数撞上
profile 切换，但本轮没有连续采样功放 sysfs，不能把这一解释当作完全验证。

这次真正收到的语音管道通知包括：

```text
cmd=0x0 channel=2 params=0x10,0x0,0x0,0x0  -> narrowband
cmd=0x0 channel=2 params=0x10,0x1,0x0,0x0  -> wideband
```

65 秒限时到达时脚本停止音频，**没有挂断电话**；当时 daemon 状态仍是 active。
随后读取状态已 idle。不能仅靠可能滞后的状态文件宣称实际通话一定保持超过一分钟，
需与用户反馈核对，也不能据此宣布自动释放问题已解决。
退出后全部 319 个 mixer 无差异，功放恢复 Music，音频 monitor 退出，PCM5 双向 closed。
**用户试听反馈：两端仍无声。此次试验未修复通话。**
因此暂不把临时路由包装器部署为正式通话程序；手机正式程序的 SHA256 保持不变。
当前已恢复 idle、原 Music 功放模式，音频 monitor 已退出，PCM5 双向 closed。
“路径上电 + profile 应用”仍未跨过有效音频数据传输这条证据边界。

证据均在 `work/voice-review-20261025/`：`native-call.jsonl`、`native-call-result.json`、
`native-call-run.log`、`native-call-audio-log.txt`、`native-call-amp-kernel.txt`、
`native-call-mixer-diff.json`。目录名沿用上一轮日期，试验发生于 2026-10-26。

## M8 的成功到底依赖什么

本地 `work/m8/README.md` 记录 M8 同为 UMS9620，但没有独立听筒。
它把逻辑 receiver 路由到物理扬声器，同时保留 Handset DSP profile。
这与 7552N 的原厂 Receiver 功放模式不能直接互换。

M8 的 6.18 音频还依赖 RAM 设备树适配：把旧 AGDSP access 节点转换为
`sprd,agdsp-pd` 的 genpd provider，补齐音频消费者 power-domains，跳过缺失的 DP 链路。
6.18 树是包含厂商音频移植的定制内核，版本号本身不是音频成功原因。

当前 7552N DT 的 sound 节点使用 `extral-iic-pa = <2>`，AW87xxx 位于 I2C 6、0x58。
6.18 的 `sprd-asoc-card-utils-hook.c` 对这个旧属性仍提前选通用 hook；
通用 hook 中旧 AW87xxx 动态查找处在 `#if 0` 内。
M8 的 `sprd,spk-ext-pa-info = <0 1 1 0>` 则选专用 AW hook。
因此直接换 M8 内核/模板仍可能遗漏 7552N 的功放启停与 Receiver 场景。

参考：[M8 项目记录](https://github.com/sprd-linux-devs/linux_device_m8/blob/main/README.md)。
具体比较以本地 checkout 为准，不把远端后续更新视为本轮测试结果。

## 可回移的源码差异

5.4 codec 驱动把 AP01 和 AP23 的两个 DAPM DAC widget 都命名为 `DAC`。
6.18 树把后者改为 `DAC AP23`，并增加对应 CLK_DAC 与 DACL/R 路由。
已整理小补丁 `kernel/patches/audio-codec-dac-ap23-name.patch`，接入音频构建脚本；
对缓存的 5.4 源码执行补丁适用性检查通过，尚未编译或装机。
该差异可回移，不能作为必须升级整个内核的证据，也未证明是本机无声根因。

## 决定迁移前的判断条件

1. 完成本机原厂模拟路径及内部 IIS 选择的试听对照，不能只看 DAPM On。
2. 若仍无声，定位 codec/DSP 链路是否有样本或有效时钟，核对通话初始带宽、场景初始化次序。
   只采用有驱动源码支持、受电源管理保护的观测；不重试已知挂总线的盲读/PCM。
3. 将已定位差异与 6.18 对照：小补丁优先判断能否回移；若依赖整套 genpd、IPC、
   平台驱动迁移且回移成本更高，再以工程成本选择迁移。
4. 6.18 至少先验证本机开机、存储、USB/SSH、modem 和音频，保留可回退的 5.4 基线。

30 秒自动释放仍只有 modem 结束事件，缺少直接媒体计数/释放原因；
“无 RTP 超时”是待验证解释，不能承诺修好音频必然消除释放。

本轮决策：不能宣布 5.4 技术上无解；也没有证据承诺继续修 5.4 会成功。
如果继续 5.4，应限定为能回答具体问题的下一轮：原厂 HAL 的语音场景启动顺序、
实际协商带宽与 PCM/IIS 时钟的关系、以及原厂/当前/6.18 驱动的对应实现差异。
不再反复把所有 mixer 抄一遍。如果可用观测手段仍无法区分数据流在哪一段中断，
或确认修复需要替换大批平台依赖，则选择 6.18 做可回退的 A/B 启动验证是合理的工程取舍，
理由是可维护性与验证成本，而非已经证明旧内核不可能工作。
