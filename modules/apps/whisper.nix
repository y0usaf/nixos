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
  # Get the whisper-overlay package directly from inputs
  whisper-overlay-pkg = inputs.whisper-overlay.packages.${pkgs.system}.whisper-overlay;
in {
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

  config = {
    # Always enable the module if the feature is enabled
    modules.apps.whisper.enable = true;

    # Add the whisper-overlay package directly from inputs
    home.packages = [whisper-overlay-pkg];

    # Use the Home Manager module provided by whisper-overlay
    services.realtime-stt-server = {
      enable = true;
      autoStart = true;
      device = cfg.device;
      model = cfg.model;
      modelRealtime = cfg.modelRealtime;
      language = cfg.language;
    };

    # Enable CUDA support for better performance
    nixpkgs.config.cudaSupport = true;
  };
}
