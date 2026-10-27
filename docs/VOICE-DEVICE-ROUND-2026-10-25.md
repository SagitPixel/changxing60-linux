# 畅行 60 通话音频：第一轮设备复核

日期：2026-10-25。设备：ZTE 7552N，OpenWrt 25.12.5，内核 `5.4.254-gb50db5b6224c`。
用户确认 WorkBuddy 停止操作后进行，两次来电均由用户发起并接听。

**结果：两次试听仍然双向无声；没有完成通话修复。但已排除“codec 永远无法启动”和“DSP 无观测接口”作为本轮现状的描述，修复了两个可复现的用户态问题。**

## 1. `out 0` 的含义需要纠正

实际 5.4 `sound/soc/soc-dapm.c` 的 `dapm_widget_power_read_file()` 用
`is_connected_input_ep()` / `is_connected_output_ep()` 生成首行 in/out。
它们沿有效路径递归累加可达端点，使用 endpoint cache，并受端点连接/挂起状态影响。
**这不是相邻边数，也不是路由注册数；多条路径还可能重复到达同一端点。**

文件后面的 `in/out "控件" "widget"` 才是经过连接条件筛选的相邻路径列表。
开关 On 但输出计数为 0，可以是下游开关、选择器或终端未接通，不能单凭这一行推断
`snd_soc_dapm_add_routes()` 漏注册了第二条边。

本轮空闲快照已经包含：

```text
S_NORMAL_AP01_P_CODEC: Off in 0 out 6
 out "static" "BE_IF_NORMAL_AP01_CODEC_P"
 in  "SWITCH" "FE_IF_NORMAL_AP01_P"
BE_IF_NORMAL_AP01_CODEC_P -> BE_DAI_NORMAL_AP01_CODEC_P -> Normal-Playback
```

通话中还看到了 `BE_VOICE_CODEC` 双向 `State: start`、8000 Hz、单声道 S16_LE。
这说明当前 hostless VOICE 的后端能启动；**没有重做旧 AP01 播放实验，不能宣称所有播放场景都已正常**。
本轮声卡实际为 319 个控件，用户提供的另一轮记录为 326/327，不能把这些不同状态当成同一次实验。

[5.4 DAPM 实现](https://github.com/dikeckaan/zte-ums9620-kernel-5.4.254/blob/main/sound/soc/soc-dapm.c)。

## 2. 确认并修复的启动阻断：缺少 ctypes

手机上原有 `changxing60-voice-audio selftest` 在第 51 行直接退出：

```text
ModuleNotFoundError: No module named 'ctypes'
```

`openwrt/build-rootfs.sh` 只装 `python3-light`，遗漏拆分包 `python3-ctypes`。
设备安装对应发行版的 `python3-ctypes 3.13.15-r1` 和依赖 `libffi 3.4.7-r1` 后，自检通过，
libasound 能加载，VOICE PCM 按名字解析到 `hw:0,5`，所需 profile 和节点存在。

手机取索引超时，改由电脑从官方 HTTPS 下载。独立 APK 无可信独立签名，未跳过校验；
下载同目录 `packages.adb` 后，设备用已有发布公钥验证索引为 OK，再从这个本地仓库安装。
没有执行系统升级或安装其他内核。

构建脚本及 `tools/build-alsa.sh` 都已补依赖，避免新镜像重复遗漏。

## 3. 两次通话的电源路径实测

| 项目 | 第一次：补依赖后 | 第二次：再临时补麦克风路由 |
| --- | --- | --- |
| VOICE 播放、采集后端 | 均 start | 均 start |
| Normal-Playback | On, in 1 out 4 | On, in 1 out 4 |
| DAC / Digital Power | On / On | On / On |
| Normal-Capture-AP01 | Off, in 0 out 1 | On, in 2 out 1 |
| ADC | Off | On, in 2 out 1 |
| MICBIAS1 | Off | On |
| 用户试听 | 两端无声 | 两端无声 |

原通话程序设置 `Mic Function=on`，但没有接通模拟麦克风到 ADC 的开关。
第二次先按原厂快照对主麦克风写入：

```text
ADC_1 Gain ADC_1 Capture Volume = 7
ADC_1 Mixer MIC1PGA_1 Switch = on
AUD ADC0L Switch = on
AUD ADC0R Switch = on
```

随即观察到主麦、偏置、ADC 和通话采集链点亮。20 秒后又临时将 `VBC_MUX_ADC2`
由 `ADC_IN_IIS1_ADC` 改为原厂快照的 `ADC_IN_IIS0_ADC`，仍未听到声音。
探测程序检测到通话结束后恢复这些临时设置；没有发起或挂断电话。

已把四个主麦控制纳入正常通话程序的保存、设置、恢复流程，并在转到蓝牙时释放本次模拟麦克风设置。
**ADC2 的实验性选择没有固化。** 辅麦降噪、带宽、DSP 数据路径和完整通话仍待验证。

## 4. DSP 观察并未走到死路

`tools/audio/probe-dsp-log.py` 使用公开的 `DSPLOG_CMD_LOG_ENABLE = 0x40045800`。
此驱动虽然定义为 `_IOW(..., int)`，实际实现读取 scalar arg；2 是 ARMCOM，1 是 UART。

- 空闲时开启 5 秒：无输出，多次 ENODATA。
- 第二次通话期间开启 5 秒：读出 **7100 字节，其中 5022 字节非零**。
- 开启和关闭 ioctl 均返回 0，finally 中已关闭日志。
- 文件 SHA256：`c0d2715b088c3a2582c1cda6a00dd4a4498bb5e23ebc64bde6ad49a81a14dbf9`。

这是二进制原始数据，尚未解码，不能据此声称找到了 DSP 故障原因或得到了语音采样。
但“这个接口永远读不到数据，必须有未知初始化协议”已不成立。

原有唯一语音管道监听者还在结束时正常读到了 20 字节通知：
`cmd=0x35, channel=2, params=0,0,0,0`。未额外打开第二个竞争读取者。
没有收到初始带宽通知，当前程序仍使用默认 NB profile `0x00000005`；
原厂另一通话快照是 WB `0x02020005`。这只能提示检查启动/订阅时序，不能证明本次网络一定是 WB。

## 5. 约 30 秒自动结束

用户报告两次通话约 30 秒自动挂断。本轮未发送 `AT+CHUP`、`ATH` 或其他挂断命令，
探测程序也没有挂断逻辑。modem 的事件顺序包含：

```text
^DSCI: ... state 6 ... cause 999
NO CARRIER
+SIND: 6,1,999
^CEND: 1,,104,999
+CGEV: NW DEACT ... 17
+SPIMSPDPINFO: 17,0,1,0
```

事后 `AT+CEER` 返回 `unknown`。能确认 modem 宣告通话结束，随后有网络撤销承载的通知；
**还不能确定最初释放由网络还是本机 modem 触发，也不能把 999 直接解读成“没有 RTP”。**
代码中 `rpcd` 的 30 秒说明是 RPC 请求期限，不是一个已证实的电话挂断计时器。

## 6. 验证、部署和收尾

- 修改后的程序在无通话情况下完成一次 start/stop：后端双向 start，播放与采集 codec 均 On。
- 停止前后逐项比较全部 319 个 mixer 控件：差异为空；PCM5 播放和采集均 closed。
- Python 语法检查及 `git diff --check` 通过。
- 已部署验证过的程序。部署前手机版本与仓库 HEAD 内容一致，原程序备份为
  `/root/voice-audio-before-codex-20261025.py`。
- 新程序 SHA256：`e89c8893ceacc357a26c558c09ddd6d710e6f4b05bff3d44b54091c926c66eec`。
- 手机最终空闲，音频监控进程已退出，采集任务已结束，没有切槽、刷机或换内核模块。
- 没有提交 git；既有迁移计划和分区工具未修改。

原始证据在本地 `work/voice-review-20261025/`（git 忽略）：
`dapm-idle.json`、`call1.jsonl`、`call2.jsonl`、`mixer-call1.txt`、`dsp-log-call.bin`、
`dsp-log-call.txt`、`mic-route-probe.txt`、`voice-call2-log.txt`、
`events-after-call.txt`（号码已脱敏）、`patched-start-stop-test.txt`、`patched-dapm.json`、`final-state.txt`。
两份连续采集窗口有重叠，`call1.jsonl` 也覆盖了第二次通话，按 uptime 和 state 分段解读。
可复用的只读采集工具为 `tools/audio/capture-dapm.py`，最多运行 300 秒，不读取来电号码。

## 下一步优先级

1. 固定当前内核/模块/路由基线，抓取从接听前到释放后的完整 modem、DSP 通知和日志，
   检查初始带宽事件是否发生在监听器启动之前；同时排查 30 秒释放，不能只围着 DAPM 转。
2. 有边界地验证 codec 与 DSP 之间是否真的有音频数据。DAPM On、PCM start、IPC 应答都不是声音证据。
   暂不重复已知会挂总线的 FAST/CAPTURE_DSP/VOICE_C 实验。
3. 6.18 移植仍可作为独立路线推进，但这轮证据不支持“5.4 的 DAPM 原则上不可能启动，因此必须迁移”。
   换内核也不能自动解决本机用户态缺包、路由遗漏或未确认的通话释放问题。
