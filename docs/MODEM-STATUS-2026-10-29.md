# 7552N 基带与热点出口状态（2026-10-29）

## 当前实测

本轮进入的是 Linux 6.18，而不是 Android：

- `6.18.54-7552n-probe1+ #64`
- Wi-Fi 热点 `CHANGXING60-CEAB` 正常，`wlan0` / `br-wifi` 为 UP
- 初始只有局域网路由，没有 `/dev/modem`、`/dev/stty_nr1` 和 `sipa_eth0`，因此热点能连但不能上网

临时按依赖顺序加载了 7 个同内核模块：

```text
sprd-sipc-virt-bus
sprd_modem_loader
spipe
spool
sipa-core
sipa_eth
sipa-dele
```

随后重启 vendor/AT 服务，执行已验证的 `SFUN=2` / `SFUN=4` 初始化，完成注册：

- `CPIN: READY`
- `CEREG: 2,1,...,11`
- `COPS: 46011`（中国电信）
- `ifup wan` 后 `sipa_eth0=10.66.170.132/8`
- 默认路由、运营商 DNS 已建立
- `ping -I sipa_eth0 223.5.5.5`：3/3，0% 丢包
- `nslookup openwrt.org` 成功

## 持久化修复

原 Wi-Fi 镜像虽然把这些 `.ko` 放进了 ramdisk，但 `etc/module-order` 没有列出它们，
所以重启后模块永远不加载。已把 7 个模块加入 6.18 启动顺序，并用本轮已验证的模块
替换 ramdisk 中旧副本。

新镜像：`work/boot-wifi-modem-618.img`

```text
SHA256 aca355f54525f3f3e714f79a4f6c5e518b39c6917a34f6bc4727bcc5ab6aca4a
```

已只写入并读回校验 `boot_b`（64 MiB），内核 hash 未变；没有写 `misc`、`boot_a` 或
`vendor_boot_b`。本机恢复的 `misc` 完整分区 SHA 仍为：

```text
92d376bfa39cc227c55c13cf7c0bc959209dc7514b14094f8545a67e66d6a1e2
```

本轮没有主动重启，当前运行中的蜂窝出口仍已恢复。下一次重启后应验证模块自动加载、
注册、`ifup wan` 和热点客户端公网访问；若启动失败，原有 slot 回退机制仍保持不变。
