###############################################################################
# Cemu Emulator Module
# Configuration for Wii U emulation
###############################################################################
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.cfg.gaming.emulation.wii-u;
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.cemu
    ];
  };
}
