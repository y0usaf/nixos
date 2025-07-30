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
    # gaming/balatro/* (3 files -> CONSOLIDATED!)
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
      hjem.users.${config.user.name} = {
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
    # Balatro mod management implementation (consolidated from gaming/balatro/*)
    (lib.mkIf balatroCfg.enable {
      hjem.users.${config.user.name} = let
        # Create individual git derivations for each mod to match original closure
        availableMods = {
          "steamodded" = pkgs.fetchFromGitHub {
            owner = "Steamodded";
            repo = "smods";
            rev = "b163d0c0a04bdbc97559939952660cb3f185bb93";
            hash = "sha256-M04QnkFLF7B7SRu3b5ptkJPPqrmSJiFYD13x6WgaRLU=";
          };
          "talisman" = pkgs.fetchFromGitHub {
            owner = "SpectralPack";
            repo = "Talisman";
            rev = "f2911d467e660033c4d62c9f6aade2edb7ecc155";
            hash = "sha256-kva/QqiGtoYK8fvtaDjXBNS5od/7HEj8FsHXYGxFPXg=";
          };
          "multiplayer" = pkgs.fetchFromGitHub {
            owner = "Balatro-Multiplayer";
            repo = "BalatroMultiplayer";
            rev = "495f515806f0f07a8668a6fa3221ce4cc183356b";
            hash = "sha256-u77GooQ0kjOcE/8BE8A7xHIke7bZS8YNGkUD4tFDgKw=";
          };
          "cardsleeves" = pkgs.fetchFromGitHub {
            owner = "larswijn";
            repo = "CardSleeves";
            rev = "4250089ca52d4cb2d3cf6c2fd7d0d6ae66428650";
            hash = "sha256-V7punE+kdQb1+oQItd8yC3QymO35lgQnwZL9I8sa9Gs=";
          };
          "jokerdisplay" = pkgs.fetchFromGitHub {
            owner = "nh6574";
            repo = "JokerDisplay";
            rev = "f29d18bdfbfc02f831f1e1e5292df72b9c263add";
            hash = "sha256-DVUQw3HP7ufwvnvJfqN3/DI2uQ2eGoaT4aT0kuxBNn8=";
          };
          "pokermon" = pkgs.fetchFromGitHub {
            owner = "InertSteak";
            repo = "Pokermon";
            rev = "403a1ca7a74f38de522ee546a0efb0a01c78a9db";
            hash = "sha256-cN3Qc1hXII2B6JXKDcjh1Lbl13u39cc3E8rvPx+17vw=";
          };
          "aura" = pkgs.fetchFromGitHub {
            owner = "SpectralPack";
            repo = "Aura";
            rev = "dbb6496d163d15e86b0afb6879d32b891164af05";
            hash = "sha256-4WHbRAUCHGtU/MwJeSQX9NdS7TX6zlsTffxl43f0JJA=";
          };
          "handybalatro" = pkgs.fetchFromGitHub {
            owner = "SleepyG11";
            repo = "HandyBalatro";
            rev = "bee3e6cdc4bb368a3f0233cf49e460eaa6f05e39";
            hash = "sha256-aB/ytaE3wlqWXcZ5/quEHmo4nzbKNOq3dxqpbVv1mrE=";
          };
          "stickersalwaysshown" = pkgs.fetchFromGitHub {
            owner = "SirMaiquis";
            repo = "Balatro-Stickers-Always-Shown";
            rev = "8bc6d74796aee5e78e817591ea42575099519964";
            hash = "sha256-raCsA7E7JpFjoc6/gGzpRnP7r/3lU9W3rgc9L4BdTT8=";
          };
        };
        enabledModSources = lib.filterAttrs (name: _: lib.elem name balatroCfg.enabledMods) availableMods;
        lovelyInjector = pkgs.fetchzip {
          url = "https://github.com/ethangreen-dev/lovely-injector/releases/download/v0.7.1/lovely-x86_64-pc-windows-msvc.zip";
          hash = "sha256-KjWSJugIfUOfWHZctEDKWGvNERXDzjW1+Ty5kJtEJlw=";
          stripRoot = false;
        };
      in {
        # Add ALL mod derivations as packages to ensure they appear in closure like original
        packages = lib.attrValues availableMods;

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
