# v0.1.0-preview.1 发布候选

适用 Xiaomi Pad 6S Pro 12.4（`sheng`）。首版面向已搭建 NixOS EFI 启动环境的测试者。仓库提供 B 槽启动镜像和校验文件，配套 NixOS EFI 载荷、内核与 rootfs 的版本要求不变。

## 安装边界

- 已解锁且可进入 ABL Fastboot。备份完整的 `boot_b`、`linux-boot` 和设备重要数据，将可启动的原镜像保存在电脑上。
- 已存在 `linux` 根分区和挂载到 `/boot` 的 `linux-boot` FAT ESP，ESP 上有与当前 NixOS 内核闭包匹配的 [EFI 载荷](https://github.com/DotRedstone/nixos-sheng/blob/735c224caf44da2a94c8cfa7aac9d68ef9fdc075/docs/uboot-efi-experiment_zh.md)。此预览不要求重刷或扩容 `linux`。若前置条件不满足，保留现有启动链。
- 使用附件的 `sha256sums.txt` 核对镜像，再用 `fastboot getvar product` 和 `fastboot getvar current-slot` 确认 `sheng`、活动槽 `b`。具备已知可用的配套载荷后，仅刷 `fastboot flash boot_b sheng-u-boot-boot_b.img`。保留 Android A 槽、`userdata`、GPT、身份和校准分区。
- Android 入口要求从实际 ROM 采集配置、检查启动镜像有效长度，以及 A/B DTBO 相同。安装步骤见 [ROM 配置文档](https://github.com/DotRedstone/nixos-sheng/blob/735c224caf44da2a94c8cfa7aac9d68ef9fdc075/docs/uboot-android-rom-profile_zh.md)。ROM 更新后先按原生 A 槽验证，再重新采集。
- 如果设备启动失败，从 ABL Fastboot 刷回已知可启动的 `boot_b` 备份。EFI 载荷有变时，同时按 NixOS 安装流程恢复 ESP 默认项。刷回前先检查当前槽位和 ESP 状态。

## 已知限制

- Android 直启未经 U-Boot AVB 验证。当前实机直启记录覆盖单个 ROM。PixelOS 17 的独立启动已完成，菜单兼容性尚待上机。
- 当前固件沿用 ABL 交给 B 槽的设备树。若 A/B DTBO 不同，保留两槽原镜像。比较旧、新 ROM 时应核对覆盖层中的板型和 SoC 标识，索引可能随 ROM 构建变化。离线合成设备树可检查覆盖层，但仍需实机证明 Android 由 U-Boot 直启，并确认 ABL 活动槽保持为 B。
- 目前仅有实体按键菜单与继承的屏幕输出。Android 和 NixOS 的触控、无线、音频等由各自系统和内核维护。
- Alpine 和 Debian 仅完成启动探针。Windows 与 UniXNU 不随本版提供。

首个可刷预览发布前，在同一组 `boot_b` 与 EFI 载荷上复测 NixOS、受支持 Android、冷启动、关机插墙充、TWRP 和 ABL Fastboot 回退。
