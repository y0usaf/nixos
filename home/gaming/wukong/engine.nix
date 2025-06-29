###############################################################################
# Black Myth: Wukong Engine Configuration - Nix-Maid Version
# Optimizes graphics settings for better performance
###############################################################################
{
  config,
  lib,
  ...
}: let
  cfg = config.home.gaming.wukong;
in {
  ###########################################################################
  # Module Options
  ###########################################################################
  options.home.gaming.wukong = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Black Myth: Wukong configuration";
    };
  };

  ###########################################################################
  # Module Configuration
  ###########################################################################
  config = lib.mkIf cfg.enable {
    users.users.y0usaf.maid.file.home.".local/share/Steam/steamapps/compatdata/2358720/pfx/drive_c/users/steamuser/AppData/Local/b1/Saved/Config/Windows/Engine.ini".text = lib.generators.toINI {} {
      "SystemSettings" = {
        "r.DefaultFeature.AntiAliasing" = "0";
        "pp.VignetteIntensity" = "0.0";
        "r.SceneColorFringeQuality" = "0";
        "r.SceneColorFringe.Max" = "0";
        "r.DepthOfFieldQuality" = "0";
        "r.DepthOfField.DepthBlur.Amount" = "0";
        "r.Tonemapper.GrainQuantization" = "0";
        "r.FilmGrain" = "0";
        "r.Tonemapper.Quality" = "0";
        "r.BloomQuality" = "0";
        "r.MotionBlurQuality" = "0";
        "r.AmbientOcclusionLevels" = "0";
        "r.AmbientOcclusionStaticFraction" = "0";
        "r.LensFlareQuality" = "0";
        "r.SSR.Quality" = "0";
        "r.Tonemapper.Sharpen" = "1.0";
        "r.Atmosphere" = "0";
        "r.VolumetricFog" = "0";
        "r.VolumetricFog.Quality" = "0";
        "r.EyeAdaptation.MethodOverride" = "0";
        "r.DefaultFeature.LensFlare" = "0";
        "r.DefaultFeature.Bloom" = "0";
        "r.DefaultFeature.AutoExposure" = "0";
        "r.PostProcessAAQuality" = "0";
        "r.SSS.Quality" = "0";
        "r.SSS.Scale" = "0";
        "r.ChromaticAberrationStartOffset" = "0";
      };
      "/Script/Engine.InputSettings" = {
        ConsoleKey = "Tilde";
      };
    };
  };
}
