###############################################################################
# Android Virtualization Configuration
# Waydroid Android container support:
# - Waydroid Android emulation
###############################################################################
{
  lib,
  hostHome,
  ...
}: {
  config = {
    ###########################################################################
    # Android Virtualization
    # Waydroid Android emulation
    ###########################################################################
    virtualisation.waydroid = lib.mkIf hostHome.cfg.programs.android.enable {
      enable = true; # Enable Waydroid to run Android apps on NixOS.
    };
  };
}
