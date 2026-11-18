# Sheng U-Boot

适用于 Xiaomi Pad 6S Pro 12.4（`sheng`，SM8550）的 U-Boot 移植。正常开机可从 B 槽菜单进入 NixOS 或直启兼容的 Android A 槽；NixOS 世代由 `linux-boot` 上的 systemd-boot 选择。

| 启动目标 | 验证范围 |
| --- | --- |
| NixOS 7.3.0 | 实机到达桌面，验证过冷启动、关机充电和恢复回退 |
| Android 16 | 原实机 ROM 从 U-Boot 菜单直启成功 |
| PixelOS 17 | ABL 原生 A 槽启动成功，U-Boot 直启待验证 |
| Alpine / Debian | 短时 EFI 用户态启动探针 |

## 构建

在 x86_64 Linux 主机上启用 Nix flakes，再运行：

```sh
nix build .#bootImage -o out/sheng-u-boot-boot_b.img
sha256sum out/sheng-u-boot-boot_b.img
```

预览版要求已解锁的设备、可进入 ABL Fastboot、现成的 `linux-boot` ESP，以及与 EFI 载荷匹配的 NixOS 系统。安装前阅读[兼容性与回退](docs/preview_zh.md)。NixOS 内核、EFI 载荷和 rootfs 由 [nixos-sheng](https://github.com/DotRedstone/nixos-sheng) 提供。

上游与许可见 [SOURCE.md](SOURCE.md)。
