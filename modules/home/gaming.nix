{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.home.gaming.core;
  controllersCfg = config.home.gaming.controllers;
  emuWiiUCfg = config.home.gaming.emulation.wii-u;
  emuGcnWiiCfg = config.home.gaming.emulation.gcn-wii;
  wukongCfg = config.home.gaming.wukong;
  balatroCfg = config.home.gaming.balatro;
  marvelRivalsEngineCfg = config.home.gaming.marvel-rivals.engine;
  marvelRivalsGameUserSettingsCfg = config.home.gaming.marvel-rivals.gameusersettings;
  marvelRivalsMarvelUserSettingsCfg = config.home.gaming.marvel-rivals.marvelusersettings;

  # Import npins sources to maintain exact package closure equivalence with original system
  sources = import ../../npins;

  # Balatro configuration from gaming/balatro/installation.nix  
  balatrroSources = sources;
  availableMods = {
    steamodded = {
      src = balatrroSources.smods;
      name = "smods";
    };
    talisman = {
      src = balatrroSources.Talisman;
      name = "Talisman";
    };
    cryptid = {
      src = pkgs.fetchFromGitHub {
        owner = "SpectralPack";
        repo = "Cryptid";
        rev = "1da26300f239d77be0a9ffd24a75a9f7b6af724a";
        hash = "sha256-gwehpW9HenUxbO1s2USnXSkgkOGRetoIvWEfPj3CFNc=";
      };
      name = "Cryptid";
    };
    multiplayer = {
      src = balatrroSources.BalatroMultiplayer;
      name = "BalatroMultiplayer";
    };
    cardsleeves = {
      src = balatrroSources.CardSleeves;
      name = "CardSleeves";
    };
    jokerdisplay = {
      src = balatrroSources.JokerDisplay;
      name = "JokerDisplay-1.8.4.1";
    };
    pokermon = {
      src = balatrroSources.Pokermon;
      name = "Pokermon";
    };
    stickersalwaysshown = {
      src = balatrroSources."Balatro-Stickers-Always-Shown";
      name = "StickersAlwaysShown";
    };
    handybalatro = {
      src = balatrroSources.HandyBalatro;
      name = "HandyBalatro";
    };
    aura = {
      src = balatrroSources.Aura;
      name = "Aura";
    };
    morespeeds = {
      name = "MoreSpeeds.lua";
    };
  };
  enabledMods = lib.filterAttrs (name: _mod: lib.elem name balatroCfg.enabledMods && name != "morespeeds") availableMods;
  lovelyInjectorPackage = pkgs.fetchzip {
    url = "https://github.com/ethangreen-dev/lovely-injector/releases/download/v0.7.1/lovely-x86_64-pc-windows-msvc.zip";
    sha256 = "sha256-KjWSJugIfUOfWHZctEDKWGvNERXDzjW1+Ty5kJtEJlw=";
    stripRoot = false;
  };

  # Marvel Rivals settings content
  marvelUserSettingsContent = ''
    {"MasterVolume": 70, "SoundEffectVolume": 100, "MusicVolume": 0, "VoiceVolume": 100, "UserControl": "{\"0\": \"{\\\"MouseHorizontalSensitivity\\\": 5.0, \\\"MouseVerticalSensitivity\\\": 5.0, \\\"CharControlInputMappings\\\": {\\\"6\\\": {\\\"PrimaryKey\\\": {\\\"Key\\\": \\\"J\\\"}}, \\\"24\\\": {\\\"PrimaryKey\\\": {\\\"Key\\\": \\\"B\\\"}}, \\\"36\\\": {\\\"PrimaryKey\\\": {\\\"Key\\\": \\\"None\\\"}}, \\\"46\\\": {\\\"PrimaryKey\\\": {\\\"Key\\\": \\\"X\\\"}}, \\\"47\\\": {\\\"PrimaryKey\\\": {\\\"Key\\\": \\\"Z\\\"}}}, \\\"AbilityUserSettingList\\\": [{\\\"SettingType\\\": 1, \\\"Key\\\": \\\"WakandaUp\\\", \\\"AbilityID\\\": 200401, \\\"bIsGamepad\\\": false, \\\"bIsDirty\\\": false, \\\"Value\\\": true}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"WakandaUp\\\", \\\"AbilityID\\\": 200401, \\\"bIsGamepad\\\": true, \\\"bIsDirty\\\": false, \\\"Value\\\": false}], \\\"HpBarVisibleRule\\\": 1}\", \"1035\": \"{\\\"AbilityUserSettingList\\\": [{\\\"SettingType\\\": 1, \\\"Key\\\": \\\"bIsHoldAbility\\\", \\\"AbilityID\\\": 103501, \\\"bIsGamepad\\\": false, \\\"bIsDirty\\\": false, \\\"Value\\\": true}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"bIsHoldSprint\\\", \\\"AbilityID\\\": 103501, \\\"bIsGamepad\\\": false, \\\"bIsDirty\\\": false, \\\"Value\\\": true}, {\\\"SettingType\\\": 0, \\\"Key\\\": \\\"WallRunMode\\\", \\\"AbilityID\\\": 103501, \\\"bIsGamepad\\\": false, \\\"bIsDirty\\\": false, \\\"Value\\\": \\\"TowardUp\\\"}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"bIsHoldAbility\\\", \\\"AbilityID\\\": 103501, \\\"bIsGamepad\\\": true, \\\"bIsDirty\\\": false, \\\"Value\\\": false}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"bIsHoldSprint\\\", \\\"AbilityID\\\": 103501, \\\"bIsGamepad\\\": true, \\\"bIsDirty\\\": false, \\\"Value\\\": false}, {\\\"SettingType\\\": 0, \\\"Key\\\": \\\"WallRunMode\\\", \\\"AbilityID\\\": 103501, \\\"bIsGamepad\\\": true, \\\"bIsDirty\\\": false, \\\"Value\\\": \\\"TowardUp\\\"}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"bIsHoldAbility\\\", \\\"AbilityID\\\": 103551, \\\"bIsGamepad\\\": false, \\\"bIsDirty\\\": false, \\\"Value\\\": true}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"UseSimpleSwing\\\", \\\"AbilityID\\\": 103551, \\\"bIsGamepad\\\": false, \\\"bIsDirty\\\": false, \\\"Value\\\": false}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"bIsHoldAbility\\\", \\\"AbilityID\\\": 103551, \\\"bIsGamepad\\\": true, \\\"bIsDirty\\\": false, \\\"Value\\\": false}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"UseSimpleSwing\\\", \\\"AbilityID\\\": 103551, \\\"bIsGamepad\\\": true, \\\"bIsDirty\\\": false, \\\"Value\\\": true}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"WakandaUp\\\", \\\"AbilityID\\\": 200401, \\\"bIsGamepad\\\": false, \\\"bIsDirty\\\": false, \\\"Value\\\": true}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"WakandaUp\\\", \\\"AbilityID\\\": 200401, \\\"bIsGamepad\\\": true, \\\"bIsDirty\\\": false, \\\"Value\\\": false}]}\", \"1045\": \"{\\\"AbilityUserSettingList\\\": [{\\\"SettingType\\\": 1, \\\"Key\\\": \\\"bIsHoldAbility\\\", \\\"AbilityID\\\": 104541, \\\"bIsGamepad\\\": false, \\\"bIsDirty\\\": false, \\\"Value\\\": false}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"bIsHoldAbility\\\", \\\"AbilityID\\\": 104541, \\\"bIsGamepad\\\": true, \\\"bIsDirty\\\": false, \\\"Value\\\": false}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"bIsHoldAbility\\\", \\\"AbilityID\\\": 104542, \\\"bIsGamepad\\\": false, \\\"bIsDirty\\\": false, \\\"Value\\\": true}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"bIsHoldAbility\\\", \\\"AbilityID\\\": 104542, \\\"bIsGamepad\\\": true, \\\"bIsDirty\\\": false, \\\"Value\\\": false}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"WakandaUp\\\", \\\"AbilityID\\\": 200401, \\\"bIsGamepad\\\": false, \\\"bIsDirty\\\": false, \\\"Value\\\": true}, {\\\"SettingType\\\": 1, \\\"Key\\\": \\\"WakandaUp\\\", \\\"AbilityID\\\": 200401, \\\"bIsGamepad\\\": true, \\\"bIsDirty\\\": false, \\\"Value\\\": false}]}\"}";
  '';
in {
  options = {
    # gaming/core.nix
    home.gaming.core = {
      enable = lib.mkEnableOption "core gaming packages";
    };

    # gaming/controllers.nix
    home.gaming.controllers = {
      enable = lib.mkEnableOption "gaming controller support";
    };

    # emulation/cemu.nix
    home.gaming.emulation.wii-u = {
      enable = lib.mkEnableOption "Wii U emulation via Cemu";
    };

    # emulation/dolphin.nix
    home.gaming.emulation.gcn-wii = {
      enable = lib.mkEnableOption "GameCube and Wii emulation via Dolphin";
    };

    # wukong/engine.nix
    home.gaming.wukong = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Black Myth: Wukong configuration";
      };
    };

    # gaming/balatro/installation.nix
    home.gaming.balatro = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Balatro mod management";
      };
      enableLovelyInjector = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable Lovely Injector - a runtime lua injector for LÖVE 2D games.
          This downloads and installs version.dll to enable mod loading in Balatro.
          Required for most Balatro mods to work.
        '';
      };
      enabledMods = lib.mkOption {
        type = lib.types.listOf (lib.types.enum (lib.attrNames availableMods));
        default = [];
        example = ["steamodded" "talisman" "cryptid" "multiplayer" "cardsleeves" "jokerdisplay" "pokermon" "stickersalwaysshown" "handybalatro" "aura" "morespeeds"];
        description = ''
          List of mod names to enable. Available mods:
          - steamodded: Steamodded/smods (core modding framework)
          - talisman: SpectralPack/Talisman
          - cryptid: SpectralPack/Cryptid
          - multiplayer: Balatro-Multiplayer/BalatroMultiplayer
          - cardsleeves: larswijn/CardSleeves
          - jokerdisplay: nh6574/JokerDisplay (shows joker calculations)
          - pokermon: InertSteak/Pokermon (Pokemon-themed jokers)
          - stickersalwaysshown: SirMaiquis/Balatro-Stickers-Always-Shown (keeps stickers visible on jokers)
          - handybalatro: SleepyG11/HandyBalatro (Quality of Life controls and shortcuts)
          - aura: SpectralPack/Aura (visual enhancement mod)
          - morespeeds: MoreSpeeds.lua (custom speed options)
        '';
      };
    };

    # marvel-rivals/engine.nix
    home.gaming.marvel-rivals.engine = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Marvel Rivals engine configuration";
      };
    };

    # marvel-rivals/gameusersettings.nix
    home.gaming.marvel-rivals.gameusersettings = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Marvel Rivals GameUserSettings.ini configuration";
      };
    };

    # marvel-rivals/marvelusersettings.nix
    home.gaming.marvel-rivals.marvelusersettings = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Marvel Rivals MarvelUserSettings.ini configuration";
      };
    };
  };

  config = lib.mkMerge [
    # gaming/core.nix + gaming/shader-cache.nix
    (lib.mkIf cfg.enable {
      hjem.users.y0usaf = {
        packages = with pkgs; [
          steam
          protonup-qt
          gamemode
          protontricks
          prismlauncher
        ];
        # gaming/shader-cache.nix
        files.".config/steam/steam_dev.cfg" = {
          text = ''
            unShaderBackgroundProcessingThreads ${toString config.nix.settings.max-jobs}
          '';
          clobber = true;
        };
      };
    })

    # gaming/controllers.nix
    (lib.mkIf controllersCfg.enable {
      hjem.users.y0usaf.packages = with pkgs; [
        dualsensectl
      ];
    })

    # emulation/cemu.nix
    (lib.mkIf emuWiiUCfg.enable {
      hjem.users.y0usaf.packages = [
        pkgs.cemu
      ];
    })

    # emulation/dolphin.nix
    (lib.mkIf emuGcnWiiCfg.enable {
      hjem.users.y0usaf.packages = [
        pkgs.dolphin-emu
      ];
    })

    # wukong/engine.nix
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

    # gaming/balatro/installation.nix
    (lib.mkIf balatroCfg.enable {
      hjem.users.${config.user.name}.files = lib.mkMerge [
        # MoreSpeeds mod (inline Lua)
        (lib.optionalAttrs (lib.elem "morespeeds" balatroCfg.enabledMods) {
          ".local/share/Steam/steamapps/compatdata/2379780/pfx/drive_c/users/steamuser/AppData/Roaming/Balatro/Mods/MoreSpeeds.lua" = {
            clobber = true;
            text = ''
              --- STEAMODDED HEADER
              --- MOD_NAME: More Speed
              --- MOD_ID: MoreSpeed
              --- MOD_AUTHOR: [Steamo]
              --- MOD_DESCRIPTION: More Speed options!
              --- This mod is deprecated, use Nopeus instead: https://github.com/jenwalter666/JensBalatroCollection/tree/main/Nopeus
              ----------------------------------------------
              ------------MOD CODE -------------------------
              local setting_tabRef = G.UIDEF.settings_tab
              function G.UIDEF.settings_tab(tab)
                  local setting_tab = setting_tabRef(tab)
                  if tab == 'Game' then
                      local speeds = create_option_cycle({label = localize('b_set_gamespeed'), scale = 0.8, options = {0.25, 0.5, 1, 2, 3, 4, 8, 16, 32, 64, 128, 1000}, opt_callback = 'change_gamespeed', current_option = (
                          G.SETTINGS.GAMESPEED == 0.25 and 1 or
                          G.SETTINGS.GAMESPEED == 0.5 and 2 or
                          G.SETTINGS.GAMESPEED == 1 and 3 or
                          G.SETTINGS.GAMESPEED == 2 and 4 or
                          G.SETTINGS.GAMESPEED == 3 and 5 or
                          G.SETTINGS.GAMESPEED == 4 and 6 or
                          G.SETTINGS.GAMESPEED == 8 and 7 or
                          G.SETTINGS.GAMESPEED == 16 and 8 or
                          G.SETTINGS.GAMESPEED == 32 and 9 or
                          G.SETTINGS.GAMESPEED == 64 and 10 or
                          G.SETTINGS.GAMESPEED == 128 and 11 or
                          G.SETTINGS.GAMESPEED == 1000 and 12 or
                          3 -- Default to 1 if none match, adjust as necessary
                      )})
                      local free_speed_text = {
                          n = G.UIT.R,
                          config = {
                              align = "cm",
                              id = "free_speed_text"
                          },
                          nodes = {
                              {
                                  n = G.UIT.T,
                                  config = {
                                      align = "cm",
              						scale = 0.3 * 1.5,
              						text = "Free Speed",
              						colour = G.C.UI.TEXT_LIGHT
                                  }
                              }
                          }
                      }
                      local free_speed_box = {
                          n = G.UIT.R,
                          config = {
                              align = "cm",
                              padding = 0.05,
                              id = "free_speed_box"
                          },
                          nodes = {
                              create_text_input({
                                  hooked_colour = G.C.RED,
                                  colour = G.C.RED,
                                  all_caps = true,
                                  align = "cm",
                                  w = 2,
                                  max_length = 4,
                                  prompt_text = 'Custom Speed',
                                  ref_table = G.SETTINGS.COMP,
                                  ref_value = 'name'
                              })
                          }
                      }
                      setting_tab.nodes[1] = speeds
                      -- TODO fix this
                      --table.insert(setting_tab.nodes, 2, free_speed_text)
                      --table.insert(setting_tab.nodes, 3, free_speed_box)
                  end
                  return setting_tab
              end
              ----------------------------------------------
              ------------MOD CODE END----------------------
            '';
          };
        })
        # Mod installations
        (lib.mapAttrs' (
            name: mod:
              lib.nameValuePair
              ".local/share/Steam/steamapps/compatdata/2379780/pfx/drive_c/users/steamuser/AppData/Roaming/Balatro/Mods/${mod.name}"
              {
                clobber = true;
                source = mod.src;
              }
          )
          enabledMods)
        # Lovely Injector installation
        (lib.optionalAttrs balatroCfg.enableLovelyInjector {
          ".local/share/Steam/steamapps/common/Balatro/version.dll" = {
            clobber = true;
            source = "${lovelyInjectorPackage}/version.dll";
          };
        })
      ];
    })

    # marvel-rivals/engine.nix
    (lib.mkIf marvelRivalsEngineCfg.enable {
      hjem.users.${config.user.name}.files.".local/share/Steam/steamapps/compatdata/2767030/pfx/drive_c/users/steamuser/AppData/Local/Marvel/Saved/Config/Windows/Engine.ini" = {
        clobber = true;
        text = lib.generators.toINI {} {
          "SystemSettings" = {
            "r.LevelStreamingDistanceScale" = "1";
            "r.ViewDistanceScale" = "1";
            "r.LandscapeLODBias" = "0";
            "r.LandscapeLODDistributionScale" = "1";
            "r.LandscapeLOD0DistributionScale" = "1";
            "r.LODFadeTime" = "2";
            "r.UITextureLODBias" = "-1";
            "r.Streaming.Boost" = "1";
            "r.TextureStreaming" = "1";
            "r.Streaming.ScaleTexturesByGlobalMyBias" = "1";
            "r.Streaming.LimitPoolSizeToVRAM" = "0";
            "r.DefaultFeature.AmbientOcclusion" = "False";
            "r.DefaultFeature.AmbientOcclusionStaticFraction" = "False";
            "r.DefaultFeature.AntiAliasing" = "0";
            "r.DefaultFeature.AutoExposure" = "True";
            "r.DefaultFeature.Bloom" = "False";
            "r.DefaultFeature.LensFlare" = "False";
            "r.DefaultFeature.MotionBlur" = "False";
            "r.DepthOfFieldQuality" = "0";
            "r.DistanceFieldAO" = "0";
            "r.EmitterSpawnRateScale" = "0";
            "r.FastBlurThreshold" = "0";
            "r.LensFlareQuality" = "0";
            "r.MaterialQualityLevel" = "1";
            "r.RefractionQuality" = "0";
            "r.SceneColorFormat" = "3";
            "r.SceneColorFringeQuality" = "0";
            "r.SeparateTranslucency" = "False";
            "r.Shadow.CSM.MaxCascades" = "1";
            "r.Shadow.CSM.TransitionScale" = "0";
            "r.Shadow.DistanceScale" = "0";
            "r.Shadow.MaxResolution" = "64";
            "r.Shadow.RadiusThreshold" = "0";
            "r.ShadowQuality" = "0";
            "r.SSR.Quality" = "0";
            "r.SSS.SampleSet" = "0";
            "r.SSS.Scale" = "0";
            "r.Fog" = "0";
            "r.PostProcessAAQuality" = "0";
            "r.MotionBlurQuality" = "0";
            "r.BlurGBuffer" = "0";
            "r.MaxAnisotropy" = "0";
            "r.BloomQuality" = "0";
            "r.LightFunction" = "0";
            "r.DetailMode" = "1";
            "r.TonemapperQuality" = "0";
            "r.MaterialQuality" = "1";
            "r.DepthOfField.MaxSize" = "0";
            "r.SwitchGridShadow" = "0";
            "r.Tonemapper.Sharpen" = "0.0";
            "r.AmbientOcclusionLevels" = "0";
            "r.VolumetricFog" = "0";
            "r.FogDensity" = "0";
            "r.Atmosphere" = "0";
            "r.ParticleLightQuality" = "0";
            "FX.MaxCPUParticlesPerEmitter" = "20";
            "FX.MaxGPUParticlesSpawnedPerFrame" = "0";
            "r.ParticleLODBias" = "3";
          };
          "/script/engine.renderersettings" = {
            "r.DefaultFeature.LensFlare" = "False";
            "r.DefaultFeature.DepthOfField" = "False";
            "r.DefaultFeature.AmbientOcclusion" = "False";
            "r.DefaultFeature.AmbientOcclusionStaticFraction" = "False";
            "r.BloomQuality" = "0";
            "r.MotionBlurQuality" = "0";
            "r.FastBlurThreshold" = "0";
            "r.TranslucencyVolumeBlur" = "0";
            "r.AmbientOcclusionLevels" = "0";
            "r.AmbientOcclusionRadiusScale" = "0";
            "r.DepthofFieldQuality" = "0";
            "r.DefaultFeature.AntiAliasing" = "0";
            "r.DefaultFeature.Bloom" = "False";
            "r.MobileHDR" = "False";
            "r.Shadow.MaxResolution" = "0";
            "r.Shadow.MaxCSMResolution" = "0";
            "r.Streaming.Boost" = "0.1";
            "r.SSR" = "0";
            "r.PostProcessAAQuality" = "0";
            "r.BlurGBuffer" = "0";
            "r.Fog" = "0";
            "r.TranslucentLightingVolume" = "0";
            "r.TriangleOrderOptimization" = "1";
            "r.Tonemapper.GrainQuantization" = "0";
            "r.TonemapperGamma" = "3";
            "r.Atmosphere" = "0";
            "r.EyeAdaptationQuality" = "1";
            "r.FullScreenMode" = "0";
            "r.IndirectLightingCache" = "0";
            "r.LightFunctionQuality" = "0";
            "r.LightShafts" = "0";
            "r.MaxCSMRadiusToAllowPerObjectShadows" = "0.01";
            "r.MipMapLODBias" = "1";
            "r.ReflectionEnvironment" = "0";
            "r.Shadow.RadiusThresholdRSM" = "0";
            "r.Shadow.TexelsPerPixel" = "0";
            "r.SimpleDynamicLighting" = "0";
            "r.UniformBufferPooling" = "1";
            "r.OptimizeForUAVPerformance" = "0";
            "r.Shadow.PerObject" = "1";
            "r.AllowLandscapeShadows" = "0";
            "r.AllowStaticLighting" = "0";
            "r.DFShadowScatterTileCulling" = "0";
            "r.ParallelShadows" = "0";
            "r.Shadow.FadeExponent" = "1";
            "r.Shadow.PreshadowExpand" = "-1";
            "r.Shadow.Preshadows" = "0";
            "r.TiledDeferredShading.MinimumCount" = "0";
            "r.AOApplyToStaticIndirect" = "0";
            "r.ContactShadows" = "0";
            "r.Shadow.PerObjectCastDistanceRadiusScale" = "0.001";
            "r.Shadow.CachePreshadow" = "1";
            "r.Shadow.CachedShadowsCastFromMovablePrimitives" = "0";
            "r.RayTracing.Translucency.Shadows" = "0";
            "r.LightMaxDrawDistanceScale" = "0.01";
            "r.CapsuleDirectShadows" = "0";
            "r.CapsuleIndirectShadows" = "0";
            "r.CapsuleMaxDirectOcclusionDistance" = "0";
            "r.CapsuleMaxIndirectOcclusionDistance" = "0";
            "r.CapsuleShadows" = "0";
            "r.Mobile.Shadow.CSMShaderCullingMethod" = "0";
            "r.Shadow.LightViewConvexHullCull" = "0";
            "r.Shadow.RectLightDepthBias" = "9";
            "r.Shadow.RectLightReceiverBias" = "0";
            "r.Shadow.TransitionScale" = "9";
          };
        };
      };
    })

    # marvel-rivals/gameusersettings.nix
    (lib.mkIf marvelRivalsGameUserSettingsCfg.enable {
      hjem.users.${config.user.name}.files.".local/share/Steam/steamapps/compatdata/2767030/pfx/drive_c/users/steamuser/AppData/Local/Marvel/Saved/Config/Windows/GameUserSettings.ini" = {
        clobber = true;
        text = lib.generators.toINI {} {
          "Internationalization" = {
            Culture = "en";
          };
          "ScalabilityGroups" = {
            "sg.ViewDistanceQuality" = "1";
            "sg.ShadowQuality" = "0";
            "sg.PostProcessQuality" = "0";
            "sg.TextureQuality" = "0";
            "sg.EffectsQuality" = "0";
            "sg.FoliageQuality" = "0";
            "sg.ShadingQuality" = "0";
            "sg.ReflectionQuality" = "0";
            "sg.GlobalIlluminationQuality" = "0";
          };
          "/Script/Engine.GameUserSettings" = {
            bUseDesiredScreenHeight = "False";
          };
          "/Script/Marvel.MarvelGameUserSettings" = {
            AntiAliasingSuperSamplingMode = "4";
            SuperSamplingQuality = "4";
            CASSharpness = "0.000000";
            ScreenPercentage = "100.000000";
            VoiceLanguage = "";
            bNvidiaReflex = "False";
            bXeLowLatency = "False";
            bDlssFrameGeneration = "False";
            bFSRFrameGeneration = "False";
            bXeFrameGeneration = "False";
            MonitorIndex = "0";
            bEnableConsole120Fps = "False";
            bUseVSync = "False";
            bUseDynamicResolution = "False";
            ResolutionSizeX = "2543";
            ResolutionSizeY = "1428";
            LastUserConfirmedResolutionSizeX = "2543";
            LastUserConfirmedResolutionSizeY = "1428";
            WindowPosX = "6";
            WindowPosY = "6";
            FullscreenMode = "2";
            LastConfirmedFullscreenMode = "2";
            PreferredFullscreenMode = "1";
            Version = "22";
            AudioQualityLevel = "0";
            LastConfirmedAudioQualityLevel = "0";
            FrameRateLimit = "0.000000";
            DesiredScreenWidth = "2560";
            DesiredScreenHeight = "1440";
            LastUserConfirmedDesiredScreenWidth = "2560";
            LastUserConfirmedDesiredScreenHeight = "1440";
            LastRecommendedScreenWidth = "-1.000000";
            LastRecommendedScreenHeight = "-1.000000";
            LastCPUBenchmarkResult = "-1.000000";
            LastGPUBenchmarkResult = "-1.000000";
            LastGPUBenchmarkMultiplier = "1.000000";
            bUseHDRDisplayOutput = "False";
            HDRDisplayOutputNits = "1000";
            bAMDAntiLag2 = "False";
            DlssFrameGenerationCount = "1";
          };
          "CareerHighLight" = {
            HighLightVideoSavedPath = "C:\\users\\steamuser\\Videos\\MarvelRivals\\Highlights";
          };
        };
      };
    })

    # marvel-rivals/marvelusersettings.nix
    (lib.mkIf marvelRivalsMarvelUserSettingsCfg.enable {
      hjem.users.${config.user.name}.files = {
        ".local/share/Steam/steamapps/compatdata/2767030/pfx/drive_c/users/steamuser/AppData/Local/Marvel/Saved/Saved/Config/default/MarvelUserSetting.ini" = {
          clobber = true;
          text = marvelUserSettingsContent;
        };
        ".local/share/Steam/steamapps/compatdata/2767030/pfx/drive_c/users/steamuser/AppData/Local/Marvel/Saved/Saved/Config/current/MarvelUserSetting.ini" = {
          clobber = true;
          text = marvelUserSettingsContent;
        };
      };
    })
  ];
}
