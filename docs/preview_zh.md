# v0.1.0-preview.1 发布说明

适用 Xiaomi Pad 6S Pro 12.4（`sheng`）。首版面向已搭建 NixOS EFI 启动环境的测试者。仓库提供 B 槽启动镜像和校验文件，配套 NixOS EFI 载荷、内核与 rootfs 的版本要求不变。

## 启动菜单

用音量键移动，电源键确认。15 秒倒计时结束时启动默认的 NixOS。

| 菜单项 | 行为 |
| --- | --- |
| `Boot NixOS` | 进入 systemd-boot 的 NixOS 世代菜单 |
| `Boot Android A directly (experimental)` | 从当前 U-Boot 启动兼容的 A 槽 Android，保留 ABL 的活动槽 |
| `Restart device` | 重启平板，再次显示启动菜单 |
| `0. Exit to U-Boot console` | 进入 U-Boot 的 `=>` 命令行。通过 USB 串口输入 `run menucmd` 可重新打开菜单 |

如果系统引导报错并返回 U-Boot，按提示确认后会回到无倒计时的菜单，可重新选择启动项。

菜单修复在 Sheng 实机通过 USB 串口验收。退出项停在 `=>` 并执行命令。临时使 Android 配置读取失败后，可返回菜单并停留超过 15 秒。从该菜单选择重启后，U-Boot USB 串口重新枚举，默认项随后启动 NixOS 7.3.0 的图形会话。另一次选择 Android 后，PixelOS 17 的 ADB 报告启动完成，Android 使用 A 槽，ABL 活动槽仍为 B。

## 刷入教程

**本版只刷 `boot_b`。** ABL 先选择活动槽，选中 B 槽才加载 U-Boot。U-Boot 随后从 `linux-boot` 加载 NixOS 的 EFI 引导器，或读取 A 槽的 `boot_a`、`vendor_boot_a`、`init_boot_a` 和 `dtbo_a` 来启动 Android。覆盖 `boot_a` 会破坏 Android 直启和原生 A 槽回退。

### 刷入前检查

- 设备已解锁，原生 Android A 槽已验证能启动。将本机可启动的 `boot_b`、完整 `linux-boot` 和重要数据备份到电脑。
- 已有 `linux` 根分区和 `linux-boot` FAT ESP，ESP 已部署与现有 NixOS 内核闭包匹配的 [EFI 载荷](https://github.com/DotRedstone/nixos-sheng/blob/735c224caf44da2a94c8cfa7aac9d68ef9fdc075/docs/uboot-efi-experiment_zh.md)。原厂布局请先准备这些分区与载荷。
- B 槽保留与 ABL 兼容的 `vendor_boot_b`、`dtbo_b`、`vbmeta_b` 和 `vbmeta_system_b`。若 B 槽曾刷入其他 ROM 或清空 `dtbo_b`，先核对本机已知可用的配套备份。实机曾因配套分区不匹配而在写入成功后回退到 A 槽。

### 校验与刷写

从同一个 Release 下载 `sheng-u-boot-boot_b.img` 和 `sha256sums.txt`，核对镜像的 SHA‑256：

```sh
grep -F '  sheng-u-boot-boot_b.img' sha256sums.txt | sha256sum -c -
```

Windows 可用 `Get-FileHash .\sheng-u-boot-boot_b.img -Algorithm SHA256`，与清单中的镜像摘要比较。

关机后按住音量下和电源键进入 ABL Fastboot，再连接电脑。以下检查应只列出目标设备，`product` 应为 `sheng`，`is-userspace` 应为 `no`，`unlocked` 应为 `yes`。记录 `current-slot`。活动槽为 `a` 时，按前置条件确认 B 槽已有经过验证的配套启动分区和 EFI 载荷。

```sh
fastboot devices
fastboot getvar product
fastboot getvar is-userspace
fastboot getvar unlocked
fastboot getvar current-slot
```

检查通过后显式写入 `boot_b`。命令使用完整分区名 `boot_b`，保留 A 槽、`dtbo_b`、`userdata`、`super`、分区表和校准分区。

```sh
fastboot flash boot_b sheng-u-boot-boot_b.img
```

看到 `OKAY` 后，若原活动槽为 `a`，执行 `fastboot set_active b`，用 `fastboot getvar current-slot` 确认返回 `b`。然后重启：

```sh
fastboot reboot
```

开机后应先出现 U-Boot 菜单，再由默认项进入 NixOS 世代菜单。已安装 Android 直启配置的设备可另测菜单里的 Android A 条目。

### 回退

若 U-Boot 未出现或系统无法启动，用音量下和电源键回到 ABL Fastboot。预先验收过的原生 Android A 槽可通过 `fastboot set_active a` 后 `fastboot reboot` 恢复启动。要恢复 B 槽，使用 `fastboot flash boot_b boot_b.before.img` 刷回本机已知可用、与 B 槽配套分区兼容的备份。若 ESP 曾变更，按 NixOS 的 EFI 回退流程恢复其载荷和默认项。

## Android A 槽直启

符合接入条件的 Sheng ROM 共用同一个 U-Boot 镜像。U-Boot 从本机 A 槽读取现有启动镜像。`capture` 从原生启动的 Android 自动采集启动设备和 fstab 后缀，`install` 将配置保存到 `linux-boot` 的 `/SHENG/ANDROID.ENV`。更换 ROM 或 OTA 后，从原生 A 槽重新采集并校验，再验证菜单直启。具体步骤见 [ROM 配置文档](https://github.com/DotRedstone/nixos-sheng/blob/735c224caf44da2a94c8cfa7aac9d68ef9fdc075/docs/uboot-android-rom-profile_zh.md)。

此预览的配置安装器检查 Sheng、A 槽、动态分区、Android v4 镜像格式与读取窗口，以及 A/B DTBO 字节一致性。直启沿用 ABL 交给 B 槽的设备树；A/B DTBO 不同时，配置安装器停止并要求核对。Android 直启未经 U-Boot AVB 验证。

## 已知限制

- 目前仅有实体按键菜单与继承的屏幕输出。Android 和 NixOS 的触控、无线、音频等由各自系统和内核维护。
- Alpine 和 Debian 仅完成启动探针。Windows 与 UniXNU 不随本版提供。

## 实机记录

本发布镜像已验证菜单退出、菜单重启、默认启动 NixOS 和直启 PixelOS 17。以下冷启动、关机充电、TWRP 和回退记录来自本发布的上一版基线，发布镜像的这些路径仍待重复验收。

2026-11-19，预览镜像从 B 槽经 U-Boot EFI 启动现有 NixOS 7.3.0 并进入桌面。关机后拔除电脑线，再连接墙充，实机直接进入电池充电画面。拔除墙充后只按电源键冷启动，默认菜单项再次进入 NixOS 桌面。从关机状态按音量加和电源进入 B 槽 TWRP，恢复环境读回的 `boot_b` 镜像与候选一致。

同一设备通过 ABL Fastboot 刷回旧 Android v0 格式的 NixOS 镜像后停在 Fastboot。重新刷入本候选的 v4 镜像，图形目标和显示管理器恢复启动，设备端读回与候选一致。该 v0 镜像在本次 B 槽配套分区下未通过回退验证。

同一候选从 U-Boot 菜单进入 PixelOS 17 桌面，ADB 报告 `sys.boot_completed=1` 与 Android 槽位 `_a`。从 Android 返回 ABL Fastboot 后，ABL 活动槽仍为 B。实机使用了 ESP 上已有的 ROM 配置，重新采集的内容与之相同。A/B DTBO 仍不同，本次结果只覆盖该设备的现有配套，未验证不匹配 DTBO 的自动配置安装。
