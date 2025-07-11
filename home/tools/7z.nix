###############################################################################
# 7z (p7zip) Archive Manager Module (Nix-Maid Version)
# Provides the 7z command via p7zip
###############################################################################
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.tools."7z";
in {
  ###########################################################################
  # Module Options
  ###########################################################################
  options.home.tools."7z" = {
    enable = lib.mkEnableOption "7z (p7zip) archive manager";
  };

  ###########################################################################
  # Module Configuration
  ###########################################################################
  config = lib.mkIf cfg.enable {
    ###########################################################################
    # Packages
    ###########################################################################
    users.users.y0usaf.maid.packages = with pkgs; [
      p7zip
    ];
  };
}
