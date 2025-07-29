{...}: {
  imports = [
    # amd.nix (9 lines -> INLINED!)
    ({
      lib,
      hostSystem,
      ...
    }: {config = {services.xserver.videoDrivers = lib.mkIf hostSystem.hardware.amdgpu.enable ["amdgpu"];};})
    # bluetooth.nix (27 lines -> INLINED!)
    ({config, lib, pkgs, hostSystem, ...}: let hardwareCfg = hostSystem.hardware; in {config = {hardware.bluetooth = lib.mkIf (hardwareCfg.bluetooth.enable or false) {enable = true; powerOnBoot = true; settings = hardwareCfg.bluetooth.settings or {General = {ControllerMode = "dual"; FastConnectable = true;};}; package = pkgs.bluez;}; services.dbus.packages = lib.mkIf (hardwareCfg.bluetooth.enable or false) [pkgs.bluez]; environment.systemPackages = lib.optionals (hardwareCfg.bluetooth.enable or false) [pkgs.bluez pkgs.bluez-tools]; users.users.${config.hostSystem.username}.extraGroups = lib.optionals (hardwareCfg.bluetooth.enable or false) ["dialout" "bluetooth" "lp"];};})
    # graphics.nix (12 lines -> INLINED!)
    ({pkgs, ...}: {
      config = {
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = [pkgs.vaapiVdpau pkgs.libvdpau-va-gl];
        };
      };
    })
    # i2c.nix (3 lines -> INLINED!)
    (_: {config = {hardware.i2c.enable = true;};})
    ./input.nix
    ./nvidia.nix
    # video.nix (7 lines -> INLINED!)
    (_: {config = {services.udev.extraRules = ''KERNEL=="video[0-9]*", GROUP="video", MODE="0660"'';};})
  ];
}
