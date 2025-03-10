{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.apps.whisper;
in {
  options.modules.apps.whisper = {
    enable = mkEnableOption "Enable whisper-overlay speech-to-text service";

    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to start whisper-overlay automatically with the graphical session";
    };

    model = mkOption {
      type = types.str;
      default = "large-v3";
      description = "Main model used to generate the final transcription (tiny, base, small, medium, large-v2, large-v3)";
    };

    modelRealtime = mkOption {
      type = types.str;
      default = "base";
      description = "Faster model used to generate live transcriptions";
    };

    language = mkOption {
      type = types.str;
      default = "";
      description = "Language code for speech recognition. Leave empty to auto-detect.";
    };

    device = mkOption {
      type = types.str;
      default = "cuda";
      description = "Device to run the models on (cuda, cpu)";
    };

    host = mkOption {
      type = types.str;
      default = "localhost";
      description = "The host to listen on";
    };

    port = mkOption {
      type = types.int;
      default = 7007;
      description = "The port to listen on";
    };

    debug = mkOption {
      type = types.bool;
      default = false;
      description = "Enable debug log output";
    };

    extraOptions = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional options to pass to the whisper-overlay service";
    };
  };

  config = mkIf cfg.enable {
    # Make the package available
    home.packages = [pkgs.whisper-overlay];

    # Configure the service
    services.realtime-stt-server = {
      enable = true;
      autoStart = cfg.autoStart;
      settings =
        {
          model = cfg.model;
          model-realtime = cfg.modelRealtime;
          language = cfg.language;
          device = cfg.device;
          host = cfg.host;
          port = cfg.port;
          debug = cfg.debug;
        }
        // cfg.extraOptions;
    };

    # Add CUDA support if available
    nixpkgs.config.cudaSupport = mkDefault true;
  };
}
