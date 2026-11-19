# 源码与许可

- U-Boot 固定到 `a06e89ab05eaa2b8344d521319399333cd760ae5`（`v2026.10-rc5`）。源码路径与完整性哈希见 `flake.lock`。[上游源码](https://github.com/u-boot/u-boot/tree/a06e89ab05eaa2b8344d521319399333cd760ae5)
- 初始 Sheng 补丁基线取自 `dianqk/nixos-android-devices` 的 `8f29bfc02bb3a8d03c4545eff1296a9ce6656337`；各补丁保留作者、来源与许可声明。[基线源码](https://github.com/dianqk/nixos-android-devices/tree/8f29bfc02bb3a8d03c4545eff1296a9ce6656337)
- 此仓库从 `nixos-sheng` 的 `735c224caf44da2a94c8cfa7aac9d68ef9fdc075` 提取，保留生成实测 B 槽镜像所用的 Nix 封装和补丁。[原始集成提交](https://github.com/DotRedstone/nixos-sheng/tree/735c224caf44da2a94c8cfa7aac9d68ef9fdc075)

U-Boot 源码及其衍生补丁按原有文件许可分发，GPL 文本在 [LICENSES/GPL-2.0.txt](LICENSES/GPL-2.0.txt)。本项目原创集成工具延续原仓库的 [MIT 许可](LICENSE)。Linux 衍生文件以其原有许可声明为准。

生成 `boot_b` 镜像所需的上游源码、补丁、配置、构建入口和工具链版本均由发布提交固定。构建仅使用 U-Boot 源码与主机工具，无需提取 ROM、设备分区或厂商二进制。

Release 的对应源码归档包含 `project/`（发布提交）与 `upstream/u-boot/`（固定版本的上游源码）。使用归档中的上游树时，在解压后的顶层运行：

```sh
nix build ./project#bootImage --no-write-lock-file \
  --override-input shengUbootSrc "path:$PWD/upstream/u-boot"
```
