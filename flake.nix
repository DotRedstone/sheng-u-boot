# ---
# Module: Sheng U-Boot
# Description: Build the Android v4 U-Boot image for the Sheng B slot
# Scope: Flake
# ---

{
  description = "U-Boot port for Xiaomi Pad 6S Pro 12.4 (sheng)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    shengUbootSrc = {
      url = "github:u-boot/u-boot/a06e89ab05eaa2b8344d521319399333cd760ae5";
      flake = false;
    };
  };

  outputs = { nixpkgs, shengUbootSrc, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      directProbe = pkgs.callPackage ./packages/sheng-uboot-android-bootimg.nix {
        androidDirectProbe = true;
        buildUBoot = pkgs.pkgsCross.aarch64-multiplatform.buildUBoot;
        inherit shengUbootSrc;
      };
      bootImage = pkgs.callPackage ./packages/sheng-uboot-android-direct-v4-bootimg.nix {
        inherit directProbe;
      };
    in {
      packages.x86_64-linux = {
        default = bootImage;
        bootImage = bootImage;
      };
    };
}
