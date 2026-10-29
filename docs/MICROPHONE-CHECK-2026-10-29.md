# 7552N 麦克风检查（2026-10-29）

环境：Linux 6.18.54 #64；使用临时 mixer 路由，测试后全部恢复，无内核或启动镜像修改。

## 实测

- AP01 `hw:0,0`：ADC 上电，但首次 4 秒请求返回 I/O error，文件没有采样数据。
- DSP capture `hw:0,2` / `FE_ST_CAPTURE_DSP`：4 秒、12 秒、20 秒请求均正常结束。
- 用户配合的 20 秒复测得到 960000 帧，48 kHz、S16_LE、双声道，`arecord rc=0`。
- 右声道 RMS 在有声段约 32～90，后段安静约 3～5；输入存在显著变化。
- 左声道除启动瞬态外固定为 -32768，没有有效交流信号；不能宣称双声道录音均正常。
- 所有 mixer 恢复成功，`agdsp_access_en` 和 `Mic Function` 均读回 off。

## 临时路径

`ag_iis1_ext_sel_v2=aud_4ad_iis0_ad0`，`S_CAPTURE_DSP_CODEC SWITCH=on`，
ADC0 从 IIS1 输入，Digital ADC In Sel=ADC，Mic Function=on，
ADC_1 Mixer MIC1PGA_1 Switch=on，ADC_1 Gain=4，AUD ADC0L/R=on，VBC ADC0 DG=24,24。
完整可复现检查工具为 `tools/audio/check-microphone.py --pcm 2 --seconds 20`。

结论：DSP capture 能连续获取对声音有响应的数据，右声道可供试听；左声道和 AP01
仍异常。人声清晰度等待试听确认；本次未验证通话上行。不要把此结果扩大为
双麦克风或所有录音场景均通过。

试听文件在 `work/microphone-check/microphone-right-listen.wav`：提取右声道，
去掉首秒启动瞬态并提高试听增益；上述测量均使用原始采样。
