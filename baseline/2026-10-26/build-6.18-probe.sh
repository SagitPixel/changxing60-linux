#!/bin/sh
# 用 sprd-linux-devs 的 6.18 树编一版 7552N 探测内核。
#
#   sh kernel/build-6.18-probe.sh
#
# 基线：work/e5linux/upstream/e5-mainline.config（E5 的通用配置）
# 覆盖：把 SoC 相关的开关换成 UMS9620（E5 是 UMS9621，M8 和我们是 9620）
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
TOP=$(cd "$HERE/.." && pwd)
K=${K:-$TOP/work/linux-e5}
O=${O:-$TOP/work/kbuild-618}
CFG=$O/7552n-config.fragment

[ -f "$K/Makefile" ] || { echo "内核树不在: $K" >&2; exit 1; }
mkdir -p "$O"

# 覆盖项。取自 M8 的 build-probe.sh，按我们的板子调整：
#  - 串口地址 0x20210000 是这颗 SoC 的，直接沿用
#  - 不开 OF_OVERLAY，我们用的是厂商 DTB，不叠 overlay
#  - 不指定 e5.openwrt 的 rootfs 循环文件，第一轮用 initramfs 起来看日志
cat > "$CFG" <<'EOF'
CONFIG_LOCALVERSION="-7552n-probe1"
CONFIG_LOCALVERSION_AUTO=n
CONFIG_CMDLINE="earlycon=sprd_serial,0x20210000,115200n8 console=tty0 console=ttyS1,115200n8 loglevel=7 log_buf_len=4M rdinit=/init panic=10 clk_ignore_unused pd_ignore_unused regulator_ignore_unused fw_devlink=permissive"
CONFIG_CMDLINE_FORCE=y
CONFIG_SPRD_UMS9621_CLK=n
CONFIG_SPRD_UMS9620_CLK=y
CONFIG_PINCTRL_SPRD_QOGIRN6LITE=n
CONFIG_PINCTRL_SPRD_QOGIRN6PRO=y
CONFIG_SPRD_QOGIRN6LITE_USB2_PHY=n
CONFIG_USB_SPRD_UMS9620_SSPHY=y
CONFIG_SPRD_UMS9620_IPA_PD=y
CONFIG_SPRD_THERMAL_R5P0=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_RD_GZIP=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_SERIAL_SPRD=y
CONFIG_SERIAL_SPRD_CONSOLE=y
# 这台机器的存储是 UFS（不是 eMMC），rootfs 在上面；UFS 起来才能 switch_root
CONFIG_SCSI=y
CONFIG_SCSI_UFSHCD=y
CONFIG_SCSI_UFSHCD_PLATFORM=y
CONFIG_SCSI_UFS_SPRD=y
CONFIG_SCSI_UFS_BSG=y
CONFIG_BLK_DEV_SD=y
CONFIG_EXT4_FS=y
# audio-legacy-dt.c 用 of_changeset_*，这些声明在 CONFIG_OF_DYNAMIC 里
CONFIG_OF_DYNAMIC=y
CONFIG_OF_OVERLAY=y
# USB 网络/主机栈改内置（第一轮不编 modules，靠这些起来后能 SSH 进去）
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_DUAL_ROLE=y
CONFIG_USB_DWC3_OF_SIMPLE=y
CONFIG_USB_SPRD_UMS9620_SSPHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_USBNET=y
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_NCM=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_STORAGE=y
CONFIG_BLK_DEV_SD=y
CONFIG_SCSI=y
CONFIG_USB_HID=y
CONFIG_HID=y
CONFIG_HID_GENERIC=y
CONFIG_NET=y
CONFIG_INET=y
CONFIG_NETDEVICES=y
CONFIG_USB_NET_DRIVERS=y
EOF

echo "=== 1/4 allnoconfig ==="
make -C "$K" O="$O" ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld CROSS_COMPILE=aarch64-linux-gnu- allnoconfig >/dev/null

echo "=== 2/4 合并配置 ==="
(cd "$O" && "$K/scripts/kconfig/merge_config.sh" -m -O "$O" "$O/.config" \
    "$TOP/work/e5linux/upstream/e5-mainline.config" "$CFG" >/dev/null 2>&1) || true

echo "=== 3/4 olddefconfig ==="
make -C "$K" O="$O" ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld CROSS_COMPILE=aarch64-linux-gnu- olddefconfig > "$O/olddefconfig.log" 2>&1 || {
    tail -30 "$O/olddefconfig.log"; exit 1; }

echo "  本地版本: $(grep '^CONFIG_LOCALVERSION=' "$O/.config" | cut -d= -f2-)"
echo "  UMS9620_CLK: $(grep -c '^CONFIG_SPRD_UMS9620_CLK=y' "$O/.config")"
echo "  QOGIRN6PRO : $(grep -c '^CONFIG_PINCTRL_SPRD_QOGIRN6PRO=y' "$O/.config")"

echo "=== 4/4 编译 Image（第一轮不编 modules，快） ==="
make -C "$K" O="$O" ARCH=arm64 LLVM=1 LLVM_IAS=1 CC=clang LD=ld.lld CROSS_COMPILE=aarch64-linux-gnu- \
    -j"${JOBS:-10}" Image > "$O/build.log" 2>&1 || {
    echo "编译失败，最后 40 行："; tail -40 "$O/build.log"; exit 1; }

ls -l "$O/arch/arm64/boot/Image" | awk '{print "Image:", $5, "字节"}'
