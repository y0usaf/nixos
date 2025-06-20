###############################################################################
# IMV Image Viewer Module
# Provides the imv image viewer
###############################################################################
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.programs.imv;
in {
  options.home.programs.imv = {
    enable = lib.mkEnableOption "imv image viewer";
  };
  config = lib.mkIf cfg.enable {
    users.users.y0usaf.maid.packages = with pkgs; [imv];
  };
}
