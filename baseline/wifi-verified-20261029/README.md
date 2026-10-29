# 7552N / 6.18 已验证 Wi-Fi 基线

2026-10-29：用户确认 2.4GHz、5GHz WPA2 热点均可连接并打开 OpenWrt 后台。
当前保存为 5GHz / channel 36 / VHT80，原 SSID 与密码，网关 192.168.8.1。
详细根因与边界见 `docs/WIFI-STATUS-2026-10-29.md`。

## 主要产物

- `boot-wifi-ipd.img`：64MiB 的已刷入完整镜像，内核 #64，保留已工作的显示与音频。
- `boot-wifi-ipd.json`：镜像、内核及替换模块哈希。
- `boot-wifi-ipd-flash-verification.json`：实际 PARTNAME 设备、整镜像读回、misc 窗口外未变证明。
- `wcn_bsp-ipd.ko`、`sprd_wlan_combo-ipd.ko`：配套已 strip 模块；未热卸载测试。
- `init`、`bcb-android.bin`、`bcb-trial.bin`：与本机恢复后的 misc 配对，不能混入旧 canonical BCB。
- `misc-restored.img`：用户恢复后的完整 1MiB 原厂 misc 备份，仅用于核对/人工恢复，日常切槽只写32字节。
- `kernel-base-and-files.json`：内核 git 基点及覆盖文件哈希。
- `kernel-source-overlay.tar.gz`：当前内核所有修改/新增源文件，共54个，含此前 UFS/显示/音频移植。
- `ALL-CHANGES.patch`、`kernel.config`：已跟踪源码 diff 与实际构建配置。
- `ipd-early-recorder.txt`：启动时 IPD=0、普通 INI 自动选择的证据。
- `ipd-5g-final-validation.txt`：5GHz / VHT80、DHCP、5/5 ping、misc 全哈希、无断言的现场记录。

## 源码复现

实际树在 Docker 卷 `changxing60-linux618` 的 `/k/linux`，输出 `/k/build`。
`work/linux-e5` 不是当前构建树。完整恢复需从 manifest 中记录的 git 基点开始覆盖源码包，
并保留删除项（如有）；覆盖包已经包含 patch 内容，不要重复应用 ALL-CHANGES.patch。
复制 kernel.config 到输出目录的 .config，使用项目的 clang18 构建镜像。

构建命令：

```sh
make -C /k/linux O=/k/build ARCH=arm64 LLVM=1 LLVM_IAS=1 CROSS_COMPILE=aarch64-linux-gnu- -j10 Image modules
```

模块取自 `/k/build/drivers/...`，不要从 M= 外部构建的另一目录复制旧文件。打包前 strip。
本次实际仅更新两个无线模块，使用已有已验证 #64 Image；它们的配对哈希在 boot JSON 内。

## 刷机边界

项目根目录下的 `baseline/wifi-resume-20261028/flash-linux-checked.py` 可以刷本轮镜像，
但脚本只从其自身目录取镜像/JSON；如使用此归档的镜像，应连同 JSON 复制回脚本目录再运行。
脚本核对当前 misc 必须等于本机恢复备份，否则停止；按 PARTNAME 找实际块设备，
刷 boot_b 并读回完整 SHA，最后固定 bs=1 / seek=2048 / count=32 写 trial。
整块比较窗口之外不变。检查生成的报告后，重启独立执行。

不得直接整分区刷 misc，不得硬编码 sda/sdc，不得用其他 BCB 替换本机配套记录。
旧通用刷机脚本和默认 init 仍可能使用另一套 canonical SHA，不能直接覆盖本基线。

## 未验收范围

互联网出口、最大吞吐、休眠、完整 WCN 断电重载。保留 keep_power_on=1，copy TX 默认关闭，
无 legacy_fw_compat。XPE 固件分段选择没有本机硬件覆盖，本机实际 IPD=0。
