# SoC 温控（sprd_thermal_r5p0）修复状态（2026-10-30）

状态：**已修复并上机验证（2026-10-30，`boot-thermal-618-v2.img`，内核 #67）。**
根因静态闭合 → 编译 → 打包 → 按 `flash-linux-checked.py` 刷 slot B → 试用启动成功。
实测见文末「上机结果」。聚合 `virtual-thermal` 与降频仍未接，见末节。

## 现象

`baseline/system-audit-20261029-213158/state.txt` 的 DEFERRED 一段长期是：

```
64270000.thermal
64280000.thermal
64290000.thermal
642a0000.thermal
64a00000.usb
```

四个 SoC 温度传感器从未绑定，`/sys/class/thermal` 里没有板级 zone。
`64a00000.usb` 是另一条线，不在本次修复范围。

## 根因

不是时钟、不是设备树缺节点，是 **nvmem provider 从未注册**。

1. `work/stock.dtb` 里四个 `thermal@270000/280000/290000/2A0000` 都是
   `sprd,thermal_r5p0`，并且每个节点都带 `nvmem-cells` /
   `nvmem-cell-names = "thm_ratio_cal"`，每个 `sensor@N` 子节点带
   `"sen_delta_cal"`。
2. probe 一开始就调 `sprd_thm_cal_read(np, "thm_ratio_cal")` →
   `of_nvmem_cell_get()`。provider 未注册时该调用返回 `-EPROBE_DEFER`，
   thermal 于是无限重试。
3. provider 是 `/soc/aon/efuse@160000`，其 DT compatible 实测为
   **`sprd,qogirn6pro-efuse`**（`work/stock.dtb`：`compatible = sprd,qogirn6pro-efuse`，
   `hwlocks = <&hwlock 8>`，`clocks = <&aonapb-gate 0x11>`）。
4. `drivers/nvmem/sprd-efuse.c` 的 match 表只有 `sprd,ums312-efuse` 和
   `sprd,qogirn6lite-efuse`。所以 efuse 设备没有驱动，provider 不存在。

`baseline/wifi-verified-20261029/ALL-CHANGES.patch` 里没有任何
`drivers/nvmem/sprd-efuse.c` 的改动，可以确认当前镜像里的 efuse 驱动就是上游原样。

### 两个曾经踩过的误判

- `boot/init` 的 `pdrv`（`ls /sys/bus/platform/drivers`）列出的是**已注册驱动**，
  `sprd-efuse` 出现在里面只说明驱动编进了内核，不代表设备绑上了。
- 没有驱动的设备不会出现在 `devices_deferred` 里，所以「efuse 不在 deferred 列表」
  正是它没绑上的证据，不是它工作正常的证据。

## 补丁

`kernel/patches/nvmem-sprd-efuse-qogirn6pro.patch`：

- 新增 `qogirn6pro_data { .blk_nums = 51, .blk_offset = 53, .blk_double = true }`
  （Unisoc 5.15 树的值），并向 `sprd_efuse_of_match[]` 加
  `{ .compatible = "sprd,qogirn6pro-efuse", .data = &qogirn6pro_data }`。
- 几何值用 DT 自洽校验：efuse 子 cell 最大偏移是 `uid-end@e8` 的 200..203，
  `51 × 4 = 204` 字节刚好覆盖；`thm*_cal` cell 在 148..170，都在范围内。
- 依赖前提在本机都满足：`CONFIG_NVMEM_SPRD_EFUSE=y`、`CONFIG_HWSPINLOCK_SPRD=y`、
  `CONFIG_THERMAL_OF=y`、`CONFIG_SPRD_THERMAL_R5P0=y`；hwlock id 8 在
  `SPRD_HWLOCKS_NUM=32` 之内。
- 已用 `git apply` 对上游 6.18 的 `sprd-efuse.c` 做过干净应用校验。

`work/build-7552n/prepare-kernel.py` 里本来就有这段（新树重跑时会自动加），
但当前 Docker 卷 `changxing60-linux618:/k/linux` 是更早打的补丁，所以镜像里没有。

未做（需要时可以单独加，本次刻意不加，保持单变量）：
`econfig.read_only = true`（`upstream/port/install.py` 有）——在 OTP 上把写路径关掉，
属于防误伤加固，不影响 probe。

## 验证计划（需要用户批准后执行）

```bash
# 1. 打补丁（编译树在 Docker 卷内）
MSYS_NO_PATHCONV=1 docker run --rm -v changxing60-linux618:/k \
  -v "D:/Changxing60linux:/repo" -w /k/linux changxing60-kbuild-618 \
  sh -c 'git apply -v /repo/kernel/patches/nvmem-sprd-efuse-qogirn6pro.patch'

# 2. 编内核（同 6.18-PORT.md 第七章第 5 步）
MSYS_NO_PATHCONV=1 docker run --rm -v changxing60-linux618:/k \
  -v "D:/Changxing60linux:/repo" -w /repo -e K=/k/linux -e O=/k/build \
  changxing60-kbuild-618 sh -c 'K=/k/linux O=/k/build sh /repo/kernel/build-6.18-probe.sh'

# 3. 打包基线用 boot-power-charge-618.img；module-order-618.txt 已于 2026-10-30
#    按线上镜像字节级还原（43 条），不再是坏的。
```

上机后只读验收：

```sh
cat /sys/kernel/debug/devices_deferred          # 四个 thermal 应消失
ls /sys/class/thermal/                           # 应出现 19 个 zone
for z in /sys/class/thermal/thermal_zone*; do
  echo "$z $(cat $z/type) $(cat $z/temp)"; done  # 温度应在合理范围（室温 20–40 ℃）
dmesg | grep -i "sprd-efuse\|efuse cal analysis failed\|register thermal zone failed"
```

判据：`devices_deferred` 里四个 thermal 消失；`/sys/class/thermal` 出现 19 个 zone
（`big7mid4`、`big7`、`mid5mid6`、`mid4`、`mid5`、`mid6`、`apcpu0`、`lit0..lit3`、
`gpu`、`apcpu1`、`ai0`、`ai1`、`mm`、`lte`、`nr0`、`nr1`）；`temp` 不是 0、
不是固定值，手捂传感器时有一致变化；`dmesg` 里没有 `efuse cal analysis failed` /
`register thermal zone failed`。

这个 19 的数是按 DT 核过的：四个控制器各自的 `sensor@N` 子节点数是 2/4/7/6，
而 `/thermal-zones` 里引用它们的索引正好铺满 0..N-1，没有越界，所以 num_sensors
与 zone 一一对应。`osctsen`/`outtsen` 两个 zone 属于 PMIC 的 tsensor（phandle 280），
不在这四个控制器里，修好后仍不会出现。

## 本次不覆盖：聚合 sensor 与降频

`/thermal-zones/soc-thmzone`（带 trips 和 cooling-maps 的那个）的 `thermal-sensors`
指向 `/virtual-sensor@0`（compatible 就是裸的 `virtual-thermal`，别名
`thm-sensor0`），它把 11 个 zone 聚合成一个。这条链上还有三处缺口，都不在本次补丁里：

1. `drivers/unisoc_platform/thermal/sprd_soc_thm.c` 的 match 只有
   `sprd,virtual-thermal`，**DT 里写的是 `virtual-thermal`** → 即使加载模块也绑不上。
   修法是给 `virtual_thermal_of_match[]` 补一条 `{ .compatible = "virtual-thermal" }`。
2. `CONFIG_UNISOC_SOC_THERMAL=m`，`sprd_soc_thm.ko` 在 `work/mod618/` 里有，
   但不在 `boot/module-order-618.txt` 里，所以当前根本不加载。
3. 它的 probe 用 `thermal_zone_get_zone_by_name()`，拿不到 zone 时返回
   `-EINVAL` 而不是 `-EPROBE_DEFER`，**必须先有 zone 再加载**，顺序不能反。

再往下 cooling-maps 指向 `/cooling-devices/cluster{0,1,2}-cooling` 和
`gpu-cooling0`/`npu-cooling0`，是另一组 vendor 驱动，未核对。

所以本次的验收只到「11 个 zone 能读温度」，不等于已经有热降频。

## 仍未验证 / 风险

- 没有任何一次真实绑定过，绑定后 `sprd_thm_sen_threshold_config` 会往硬件写阈值，
  这是本次修复第一次真正执行的热路径；如果 efuse 校准值读出异常，可能在
  `register thermal zone failed` 处失败（该错误不会是 deferred，而是直接报错）。
- `blk_double = true`（双块冗余读）是按 Unisoc 5.15 的值抄的，本机没有对照过原厂
  读出的值；如果温度整体偏移，第一嫌疑是这个几何参数。
- 温控起来后 `sprd_thermal_r5p0` 会周期性读硬件，是否有功耗影响未测。

---

## 上机结果（2026-10-30）

**当前线上镜像：`boot-thermal-618-v2.img`**，sha256 `d6e0e927…780cb`，内核
`1706ac3a…922f7`（`#67`）替换 `197075a8…033a`（`#64`），ramdisk 与
`boot-power-charge-618.img` 逐字节相同。纯 slot B 试用启动，SSH 未参与引导。

第一版 `boot-thermal-618.img`（`f34997e7…84eb5`，`#66`）也启动成功，温控同样
全通，但 `loaded=42 failed=1`：`sprd-dmaengine-pcm.ko` 缺
`ums9620_audcpglb_gate_read`。原因是编译树的 `ums9620-clk.c` 丢了一段诊断代码，
与本修复无关，属重编纪律问题（见 `PITFALLS-2026-10-28.md` §4.7）。按 overlay 还原
源码后重编得到 v2，`loaded=43 failed=0`。

v2 验收：

| 项 | 期望 | 实测 |
| --- | --- | --- |
| `uname` 版本与 build | `#67` | `6.18.54-7552n-probe1+ #67` |
| 启动模块 | 43 全成 | `loaded=43 failed=0`，`insmod-fail` 0 条 |
| 四个 thermal 绑定 | `sprd-thermal-r5p0` | `64270000/64280000/64290000/642a0000.thermal` 全部绑定 |
| efuse provider | 绑定 | `64160000.efuse → sprd-efuse` |
| `devices_deferred` | 四个 thermal 消失 | 只剩 `64a00000.usb`（历史遗留，与本次无关） |
| zone 数 | 19 SoC + 板级 | 24 = 19 SoC + `chg/nr/pa/board` + `battery` |
| 温度合理性 | 20–50 ℃ | 35.8–49.4 ℃，各 zone 互不相同、随时间漂移 |
| 声卡 / 无线 / 显示 | 不回退 | `card0 = sprdphone-sc2730`、`wlan0` 在、`card0-DSI-1` 在 |

19 个 SoC zone 实测名：`big7mid4 / big7 / mid5mid6 / mid4 / mid5 / mid6 / apcpu0 /
lit0..lit3 / gpu / apcpu1 / ai0 / ai1 / mm / lte / nr0 / nr1`，与 DT 推算的
2+4+7+6 完全一致。

顺带确认：`64400000.spi:pmic@0:adc@504` 早期在 `big_scale_calib1` 拿到
`-517`（= `-EPROBE_DEFER`）后重试绑定成功，属正常的 provider 就绪顺序，
不是回归。

**仍然没有 trip point、没有 cooling device**：`virtual-sensor@0` 依旧未绑定
（`sprd_soc_thm.ko` 未编、未在模块表里、DT compatible 也对不上），所以
`/sys/class/thermal/thermal_zone*/trip_point_*` 全为空。温度可读 ≠ 会降频，
下一节的三处缺口照旧。
