###############################################################################
# Android Module (Maid)
# Provides Android development and interaction tools
# - Waydroid for running Android in a container
# - Android debugging tools (adb, fastboot)
# - Screen mirroring with scrcpy
###############################################################################
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.programs.android;
in {
  ###########################################################################
  # Module Options
  ###########################################################################
  options.home.programs.android = {
    enable = lib.mkEnableOption "android tools and waydroid";
  };

  ###########################################################################
  # Module Configuration
  ###########################################################################
  config = lib.mkIf cfg.enable {
    ###########################################################################
    # Maid Configuration
    ###########################################################################
    users.users.y0usaf.maid = {
      ###########################################################################
      # Packages
      ###########################################################################
      packages = with pkgs; [
        waydroid
        android-tools
        scrcpy
      ];

      ###########################################################################
      # File Configuration
      ###########################################################################
      file.home = {
        ".android_env".text = ''
          # Android environment variables
          export ANDROID_HOME="$XDG_DATA_HOME/android"
          export ADB_VENDOR_KEY="$XDG_CONFIG_HOME/android"
        '';
      };

      ###########################################################################
      # Systemd Services
      ###########################################################################
      systemd.user.services = {
        waydroid-container = {
          Unit = {
            Description = "Waydroid Container";
            After = ["graphical-session.target"];
            PartOf = ["graphical-session.target"];
            Requires = ["waydroid-container.service"];
          };
          Service = {
            Type = "simple";
            Environment = [
              "WAYDROID_EXTRA_ARGS=--gpu-mode host"
              "LIBGL_DRIVER_NAME=nvidia"
              "GBM_BACKEND=nvidia-drm"
              "__GLX_VENDOR_LIBRARY_NAME=nvidia"
            ];
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
            ExecStart = "${pkgs.waydroid}/bin/waydroid session start";
            ExecStop = "${pkgs.waydroid}/bin/waydroid session stop";
            Restart = "on-failure";
            RestartSec = "5s";
          };
          Install = {
            WantedBy = ["graphical-session.target"];
          };
        };
      };
    };
  };
}
