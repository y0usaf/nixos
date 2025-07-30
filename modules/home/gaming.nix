{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.home.gaming.core;
  emuWiiUCfg = config.home.gaming.emulation.wii-u;
  emuGcnWiiCfg = config.home.gaming.emulation.gcn-wii;
  wukongCfg = config.home.gaming.wukong;
  controllersCfg = config.home.gaming.controllers;
  # Balatro npins removed - module was consolidated elsewhere
  # Balatro mods configuration removed - module was consolidated elsewhere
  # Balatro enabled mods removed - module was consolidated elsewhere
  # Lovely injector package removed - balatro module was consolidated elsewhere
in {
  options = {
    home.gaming.core = {
      enable = lib.mkEnableOption "core gaming packages";
    };
    # gaming/controllers.nix (17 lines -> INLINED\!)
    home.gaming.controllers = {
      enable = lib.mkEnableOption "gaming controller support";
    };
    # emulation/cemu.nix (17 lines -> INLINED\!)
    home.gaming.emulation.wii-u = {
      enable = lib.mkEnableOption "Wii U emulation via Cemu";
    };
    # emulation/dolphin.nix (17 lines -> INLINED\!)
    home.gaming.emulation.gcn-wii = {
      enable = lib.mkEnableOption "GameCube and Wii emulation via Dolphin";
    };
    # wukong/engine.nix (54 lines -> INLINED\!)
    home.gaming.wukong = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Black Myth: Wukong configuration";
      };
    };
    # Balatro options removed - module was consolidated elsewhere
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [
        steam
        protonup-qt
        gamemode
        protontricks
        prismlauncher
      ];
      # gaming/shader-cache.nix (10 lines -> INLINED\!)
      hjem.users.${config.user.name}.files.".config/steam/steam_dev.cfg" = {
        text = ''
          unShaderBackgroundProcessingThreads ${toString config.nix.settings.max-jobs}
        '';
        clobber = true;
      };
    })
    (lib.mkIf controllersCfg.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [
        dualsensectl
      ];
    })
    (lib.mkIf emuWiiUCfg.enable {
      hjem.users.${config.user.name}.packages = [
        pkgs.cemu
      ];
    })
    (lib.mkIf emuGcnWiiCfg.enable {
      hjem.users.${config.user.name}.packages = [
        pkgs.dolphin-emu
      ];
    })
    (lib.mkIf wukongCfg.enable {
      hjem.users.${config.user.name}.files.".local/share/Steam/steamapps/compatdata/2358720/pfx/drive_c/users/steamuser/AppData/Local/b1/Saved/Config/Windows/Engine.ini" = {
        clobber = true;
        text = lib.generators.toINI {} {
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
    })
    # Balatro configuration removed - module was consolidated elsewhere
  ];
}