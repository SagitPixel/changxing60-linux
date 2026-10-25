# bootlinux-app —— 一键从 Android 重启到 OpenWrt

一个 17 KB 的安卓应用，点一下按钮就把手机切到 slot b 的 Linux。替代每次插电脑跑 `work/arm-linux.sh`。

## 它做什么

和 `work/arm-linux.sh` 完全一样，只是省掉了 adb：

1. 往 `/dev/block/by-name/misc` 的**偏移 2048** 写 32 字节的 `bootloader_control`，把 slot b 标成待启动
2. 读回来逐字节核对，不一致就不重启
3. `reboot`

boot_b 上的系统镜像**不动**，只改这一个标志位。Linux 起不来时 LK 会自己落回 Android。
想回 Android：在 Linux 里 `poweroff -f`，或者正常重启即可（默认还是 Android）。

## 装机

```sh
sh tools/bootlinux-app/build.sh
adb install -r tools/bootlinux-app/out/bootlinux.apk
```

需要 root（Magisk 的 `su`）。应用启动时会自己检查：`id -u` 是不是 0、当前槽位是不是 `_a`。
槽位不是 `_a` 会给出警告——那时候写进去的标志可能对不上。

## 构建

不依赖 Gradle，只用 SDK 自带的 `aapt2` / `d8` / `zipalign` / `apksigner` 加 `javac`：

```
AndroidManifest.xml          清单（没有 res/，标签直接写在清单里）
src/cn/changxing60/bootlinux/MainActivity.java   全部逻辑，UI 也是代码画的
build.sh                     构建脚本
debug.keystore               自签调试证书（首次构建时生成）
```

`debug.keystore` 是提交进仓库的，密码固定为 `android`。这么做只是为了重编后还能
`adb install -r` 覆盖安装——换一个证书就得先卸载。它是调试证书，别拿去签任何要发出去的东西。

`build.sh` 里有几处是 Windows + Git Bash 的坑，改的时候注意：

- SDK 里的工具是 Windows 程序，`/d/...` 这种路径它们不认，每个路径都要过 `cygpath -w`
- `build-tools` 下 `d8` / `apksigner` 只有 `.bat`，那个没后缀的 `d8` 是 Unix 壳脚本，在 Git Bash 下跑不起来
- Git Bash 没带 `zip`，打 dex 进 APK 用 Python 的 `zipfile`

## 那 32 字节是什么

``` 
5f 62 00 00 42 43 41 42 01 02 00 00 fe 00 2f 00
00 00 00 00 00 00 00 00 00 00 00 00 00 1c 75 15 54
```

开头 `5f 62` 是 bootloader_control 的魔数，`42 43 41 42` 是 "BCAB"（bootloader control A/B）。
和 `work/boot-linux-slotb.misc-slot-b-trial.bin` 是同一份。改了 slot 布局的话这个要重新生成，
别手改。

## 验证过的

2026-10-25 在 7552N 上实测：装好后点按钮 → 确认 → 约 3 分钟进到
`Linux 5.4.254-gb50db5b6224c aarch64`。
