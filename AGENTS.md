# AGENTS.md

本仓库维护 Xiaomi Pad 6S Pro 12.4（sheng）的 U-Boot 移植、Android v4 封装和 ROM 配置采集工具。NixOS rootfs、EFI 载荷和内核由各自项目维护。

- 先运行 `git status --short`，保留已有改动。分别提交行为、构建和文档变更。
- 保留上游和补丁的作者、来源与许可证。只有明确更新依赖时才改 `flake.lock`。
- 本地验证运行 `python3 scripts/test-sheng-android-rom-config.py` 和 `nix build .#bootImage`。区分构建、哈希核对与实机验收。
- 上机前确认目标设备、槽位、Fastboot 和可启动的 `boot_b` 备份。不要把本项目镜像刷到 Android A 槽。
- 设备备份、ROM 启动配置、校准分区、部署值和构建产物保留在 Git 之外。
