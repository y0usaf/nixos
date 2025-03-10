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
      default = "base.en";
      description = "Whisper model to use (tiny.en, base.en, small.en, medium.en, large-v2)";
    };

    language = mkOption {
      type = types.str;
      default = "en";
      description = "Language code for speech recognition";
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
          language = cfg.language;
        }
        // cfg.extraOptions;
    };

    # Add CUDA support if available
    nixpkgs.config.cudaSupport = mkDefault true;
  };
}
