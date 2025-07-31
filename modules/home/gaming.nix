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
  balatroCfg = config.home.gaming.balatro;
  # Import npins sources to maintain exact package closure equivalence with original system
  sources = import ../../npins;
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
    # gaming/balatro/* (3 files -> CONSOLIDATED\!)
    home.gaming.balatro = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Balatro mod management";
      };
      enableLovelyInjector = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Lovely Injector for mod loading";
      };
      enabledMods = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of enabled Balatro mods";
        example = ["steamodded" "talisman" "multiplayer"];
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      hjem.users.y0usaf = {
        packages = with pkgs; [
          steam
          protonup-qt
          gamemode
          protontricks
          prismlauncher
        ];
        # gaming/shader-cache.nix (10 lines -> INLINED\!)
        files.".config/steam/steam_dev.cfg" = {
          text = ''
            unShaderBackgroundProcessingThreads ${toString config.nix.settings.max-jobs}
          '';
          clobber = true;
        };
      };
    })
    (lib.mkIf controllersCfg.enable {
      hjem.users.y0usaf.packages = with pkgs; [
        dualsensectl
      ];
    })
    (lib.mkIf emuWiiUCfg.enable {
      hjem.users.y0usaf.packages = [
        pkgs.cemu
      ];
    })
    (lib.mkIf emuGcnWiiCfg.enable {
      hjem.users.y0usaf.packages = [
        pkgs.dolphin-emu
      ];
    })
    (lib.mkIf wukongCfg.enable {
      hjem.users.y0usaf.files.".local/share/Steam/steamapps/compatdata/2358720/pfx/drive_c/users/steamuser/AppData/Local/b1/Saved/Config/Windows/Engine.ini" = {
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

    # Balatro mod management implementation (consolidated from gaming/balatro/*)
    (lib.mkIf balatroCfg.enable {
      hjem.users.y0usaf = let
        # Use npins sources for available mods, with cryptid as fetchFromGitHub
        availableMods = {
          "steamodded" = sources.smods;
          "talisman" = sources.Talisman;
          "multiplayer" = sources.BalatroMultiplayer;
          "cardsleeves" = sources.CardSleeves;
          "jokerdisplay" = sources.JokerDisplay;
          "pokermon" = sources.Pokermon;
          "aura" = sources.Aura;
          "handybalatro" = sources.HandyBalatro;
          "stickersalwaysshown" = sources."Balatro-Stickers-Always-Shown";
          # Add cryptid from fetchFromGitHub (was in original system)
          "cryptid" = pkgs.fetchFromGitHub {
            owner = "SpectralPack";
            repo = "Cryptid";
            rev = "1da26300f239d77be0a9ffd24a75a9f7b6af724a";
            hash = "sha256-gwehpW9HenUxbO1s2USnXSkgkOGRetoIvWEfPj3CFNc=";
          };
        };
        enabledModSources = lib.filterAttrs (name: _: lib.elem name balatroCfg.enabledMods) availableMods;
        lovelyInjector = pkgs.fetchzip {
          url = "https://github.com/ethangreen-dev/lovely-injector/releases/download/v0.7.1/lovely-x86_64-pc-windows-msvc.zip";
          hash = "sha256-KjWSJugIfUOfWHZctEDKWGvNERXDzjW1+Ty5kJtEJlw=";
          stripRoot = false;
        };
      in {
        # Direct npins source references - let Nix handle the package naming
        packages = lib.optionals balatroCfg.enable [
          sources.BalatroMultiplayer
          sources.CardSleeves
          sources.JokerDisplay
          sources.Pokermon
          sources.Talisman
          sources.smods
        ];

        files = lib.mkMerge [
          # Lovely Injector installation
          (lib.mkIf balatroCfg.enableLovelyInjector {
            ".local/share/Steam/steamapps/compatdata/2379780/pfx/drive_c/users/steamuser/AppData/Roaming/Balatro/version.dll" = {
              source = "${lovelyInjector}/version.dll";
              clobber = true;
            };
          })
          # Mod installations
          (lib.mkMerge (lib.mapAttrsToList (modName: modSource: {
              ".local/share/Steam/steamapps/compatdata/2379780/pfx/drive_c/users/steamuser/AppData/Roaming/Balatro/Mods/${modName}" = {
                source = modSource;
                clobber = true;
              };
            })
            enabledModSources))
          # MoreSpeeds mod (inline Lua)
          (lib.mkIf (lib.elem "morespeeds" balatroCfg.enabledMods) {
            ".local/share/Steam/steamapps/compatdata/2379780/pfx/drive_c/users/steamuser/AppData/Roaming/Balatro/Mods/MoreSpeeds.lua" = {
              text = ''
                --- STEAMODDED HEADER
                --- MOD_NAME: More Speeds
                --- MOD_ID: MoreSpeeds
                --- MOD_AUTHOR: [y0usaf]
                --- MOD_DESCRIPTION: Adds more game speed options

                local speeds = {0.25, 0.5, 0.75, 1, 1.25, 1.5, 2, 3, 4, 8}
                G.SPEEDFACTOR = speeds[G.SETTINGS.GAMESPEED] or 1
              '';
              clobber = true;
            };
          })
        ];
      };
    })
  ];
}
