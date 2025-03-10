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
}
