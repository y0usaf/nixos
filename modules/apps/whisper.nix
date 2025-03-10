{
  config,
  lib,
  pkgs,
  inputs,
  profile,
  ...
}:
with lib; let
  cfg = config.modules.apps.whisper;
  featureEnabled = builtins.elem "whisper" profile.features;
in {
  # Import the whisper module when the feature is enabled
  imports = lib.optional featureEnabled ./apps/whisper.nix;

  # Enable the module when the feature is enabled
  config = lib.mkIf featureEnabled {
    modules.apps.whisper = {
      enable = true;
      model = "large-v3";
      modelRealtime = "base";
      device = "cuda"; # Change to "cpu" if you don't have CUDA support
      language = ""; # Auto-detect language
    };
  };

  options.modules.apps.whisper = {
    enable = mkEnableOption "Enable whisper speech-to-text overlay";

    model = mkOption {
      type = types.str;
      default = "large-v3";
      description = "Main model used to generate the final transcription";
    };

    modelRealtime = mkOption {
      type = types.str;
      default = "base";
      description = "Faster model used to generate live transcriptions";
    };

    device = mkOption {
      type = types.str;
      default = "cuda";
      description = "Device to run the models on (cuda or cpu)";
    };

    language = mkOption {
      type = types.str;
      default = "";
      description = "Set the spoken language. Leave empty to auto-detect.";
    };
  };

  config = mkIf cfg.enable {
    # Enable the realtime-stt-server service
    services.realtime-stt-server = {
      enable = true;
      device = cfg.device;
      model = cfg.model;
      modelRealtime = cfg.modelRealtime;
      language = cfg.language;
    };

    # Add the whisper-overlay package to user packages
    home.packages = [pkgs.whisper-overlay];

    # Create a simple script to start the overlay
    home.file.".config/scripts/start-whisper-overlay.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        whisper-overlay overlay --hotkey KEY_RIGHTCTRL
      '';
    };

    # Add autostart entry for Hyprland if that feature is enabled
    xdg.configFile = mkIf (builtins.elem "hyprland" profile.features) {
      "hypr/autostart.d/whisper-overlay.sh" = {
        executable = true;
        text = ''
          #!/bin/sh
          ${config.home.homeDirectory}/.config/scripts/start-whisper-overlay.sh &
        '';
      };
    };
  };
}
