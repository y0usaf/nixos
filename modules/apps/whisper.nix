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
    # Add the whisper-overlay package to user packages
    home.packages = [pkgs.whisper-overlay];

    # Configure the realtime-stt-server service directly
    systemd.user.services.realtime-stt-server = {
      Unit = {
        Description = "Realtime STT Server for whisper-overlay";
        After = ["network.target"];
      };

      Service = {
        ExecStart = "${pkgs.whisper-overlay}/bin/realtime-stt-server --device ${cfg.device} --model ${cfg.model} --model-realtime ${cfg.modelRealtime} ${optionalString (cfg.language != "") "--language ${cfg.language}"}";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
