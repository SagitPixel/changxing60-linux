# 6.18 可启动基线（2026-10-26）

这是**第一个能稳定运行**的 6.18 版本快照。设备在当时状态下：8 核、3.4GB、
usb0 网络、telnet 可用，`/proc/asound/cards` 为空，UFS 未启用（崩溃后已撤销匹配）。

## 内容

| 文件 | 说明 | 大小 |
|---|---|---|
| `Image` | 编译产物（arm64 内核） | 26 MB |
| `Image.lk` | 加了 LK 跳转桩的版本（刷机用这个） | 28 MB |
| `boot-618-slotb.img` | 完整 boot 镜像（v4，含 5.4 ramdisk），**这就是刷进 boot_b 的** | 64 MB |
| `boot-5.4-fallback.img` | 原来能跑的 5.4 镜像，**回退用** | 64 MB |
| `boot-linux-slotb.misc-slot-b-trial.bin` | misc 的 32 字节 slot-b 控制 | 32 B |
| `config-7552n-probe1` | 最终内核配置（208 KB，全量） | 208 KB |
| `modules-618.tar.gz` | 232 个配套 .ko | 95 MB |
| `ALL-CHANGES.patch` | **相对于上游提交的全部改动（33 个文件）** | 756 KB |
| `KERNEL_COMMIT.txt` | 上游基线提交 | |
| `build-6.18-probe.sh` / `Dockerfile.618` | 构建脚本与工具链定义 | |
| `SHA256SUMS.txt` | 全部产物的哈希 | |

## 上游基线

见 `KERNEL_COMMIT.txt`。内核树在 Docker 卷 `changxing60-linux618` 的 `/k/linux`。

## 恢复到这一版

```bash
# 刷回本基线（设备需在 Android）
adb push boot-618-slotb.img /data/local/tmp/cx.img
adb push boot-linux-slotb.misc-slot-b-trial.bin /data/local/tmp/cx-bcb.bin
adb shell "su -c 'dd if=/data/local/tmp/cx.img of=/dev/block/by-name/boot_b bs=4M; sync'"
adb shell "su -c 'dd if=/data/local/tmp/cx-bcb.bin of=/dev/block/by-name/misc bs=1 seek=2048 conv=notrunc'"
adb shell "su -c 'reboot'"

# 回到 Android（当前唯一可靠方式：让引导器判定启动失败后回退）
# 注意：不要用 echo c > /proc/sysrq-trigger 作为日常切系统手段，
#       这会把当前内核判为崩溃。首选方法见 README 末尾「切系统」。
```

## 从本基线重建

```bash
# 1. 内核树（已存在则跳过）
docker volume create changxing60-linux618
docker run --rm -v changxing60-linux618:/k changxing60-kbuild-618 \
  sh -c 'git clone --depth 1 --branch e5-6.18 -c core.symlinks=true \
         https://github.com/sprd-linux-devs/linux.git /k/linux'

# 2. 应用全部改动
docker run --rm -v changxing60-linux618:/k -v "$PWD:/b" changxing60-kbuild-618 \
  sh -c 'cd /k/linux && git apply --binary /b/ALL-CHANGES.patch'

# 3. 编
docker run --rm -v changxing60-linux618:/k -v "$PWD:/repo" -w /repo \
  -e K=/k/linux -e O=/k/build changxing60-kbuild-618 \
  sh -c 'K=/k/linux O=/k/build sh ./build-6.18-probe.sh'
```

## 这一版的已知问题

1. **声卡未注册** —— `sprd-codec-ump9620`（`audio-codec@1000`）deferred probe 超时（-110），
   声卡缺 codec 组件。详见 `docs/6.18-PORT.md` 第二节。
2. **UFS 未启用** —— 驱动 `sprd,ufshc` 匹配项已撤销，避免 probe 崩溃。
   没有 UFS 就没有块设备、没有 rootfs、没有界面。
3. **initramfs 仍在加载 5.4 模块** —— `/linux-modules/*.ko` 是 5.4 的，
   在 6.18 上 insmod 全部失败（`invalid module format`）。这是待清理项。
