let
  sources = import ./npins;
  system = "x86_64-linux";

  # Consolidated overlays from lib/overlays/
  overlays = [
    # neovim-nightly overlay
    (import (sources.neovim-nightly-overlay))

    # Fast Font overlay
    (final: prev: {
      fast-font = final.callPackage (sources.Fast-Font + "/package.nix") {};
    })

    # Lib extensions overlay
    (final: prev: {
      lib = prev.lib.extend (lfinal: lprev: {
        # User config builder from lib/user-config.nix
        buildUserConfig = {
          username,
          homeDirectory ? "/home/${username}",
          packages ? [],
          files ? {},
          services ? {},
          programs ? {},
          xdg ? {},
          ...
        }: {
          inherit username homeDirectory;
          home = {
            inherit packages;
            file = files;
            inherit services programs;
            xdg =
              xdg
              // {
                userDirs = {
                  enable = true;
                  createDirectories = true;
                  desktop = "${homeDirectory}/Desktop";
                  download = "${homeDirectory}/Downloads";
                  templates = "${homeDirectory}/Templates";
                  publicShare = "${homeDirectory}/Public";
                  documents = "${homeDirectory}/Documents";
                  music = "${homeDirectory}/Music";
                  pictures = "${homeDirectory}/Pictures";
                  videos = "${homeDirectory}/Videos";
                };
              };
          };
        };
      });
    })
  ];

  # Direct pkgs with all overlays
  pkgs = import sources.nixpkgs {
    inherit system;
    inherit overlays;
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };

  inherit (pkgs) lib;

  # ALL MODULE IMPORTS CONSOLIDATED HERE
  allModules = {
    # System modules
    system = {
      boot = import ./modules/system/boot;
      core = import ./modules/system/core;
      hardware = import ./modules/system/hardware;
      networking = import ./modules/system/networking;
      programs = import ./modules/system/programs;
      security = import ./modules/system/security;
      services = import ./modules/system/services;
      users = import ./modules/system/users;
      virtualization = import ./modules/system/virtualization;
    };

    # Home modules
    home = {
      core = import ./modules/home/core;
      dev = import ./modules/home/dev;
      gaming = import ./modules/home/gaming;
      programs = import ./modules/home/programs;
      services = import ./modules/home/services;
      shell = import ./modules/home/shell;
      tools = import ./modules/home/tools;
      ui = import ./modules/home/ui;
    };
  };

  # User configurations
  userConfigs = {
    y0usaf = import ./configs/users/y0usaf {inherit pkgs;};
    guest = import ./configs/users/guest {inherit pkgs;};
  };

  # Host configuration
  hostConfig = import ./configs/hosts/y0usaf-desktop {inherit pkgs;};
  inherit (hostConfig) users;
  hostUserConfigs = lib.genAttrs users (username: userConfigs.${username});
in {
  inherit lib;
  formatter.${system} = pkgs.alejandra;

  nixosConfigurations.y0usaf-desktop = import (sources.nixpkgs + "/nixos") {
    inherit system;
    configuration = {
      imports = [
        # Import ALL modules at once
        allModules.system.boot
        allModules.system.core
        allModules.system.hardware
        allModules.system.networking
        allModules.system.programs
        allModules.system.security
        allModules.system.services
        allModules.system.users
        allModules.system.virtualization

        # 🔥 SYSTEM LEVEL WRAPPER BYPASS - COMMENTED OUT DUE TO CONFLICTS 🔥
        # These cause conflicts because they're already imported via allModules.system.*
        # The system modules need to be completely replaced, not bypassed

        # # From modules/system/boot/default.nix (6 lines -> OBLITERATED)
        # (import ./modules/system/boot/kernel.nix)
        # (import ./modules/system/boot/loader.nix)
        #
        # # From modules/system/programs/default.nix (6 lines -> OBLITERATED)
        # (import ./modules/system/programs/hyprland.nix)
        # (import ./modules/system/programs/obs.nix)
        #
        # # From modules/system/virtualization/default.nix (6 lines -> OBLITERATED)
        # (import ./modules/system/virtualization/android.nix)
        # (import ./modules/system/virtualization/containers.nix)
        #
        # # From modules/system/users/default.nix (5 lines -> OBLITERATED)
        # (import ./modules/system/users/accounts.nix)

        # INLINED TINY MODULES START HERE
        # From modules/system/security/polkit.nix (5 lines -> inlined)
        ({...}: {
          config = {
            security.polkit.enable = true;
          };
        })

        # 🔥 MASS INLINE OPERATION - TINY MODULES OBLITERATED! 🔥

        # REMOVED - niri options causing conflicts with ui module

        # REMOVED - nvim options causing conflicts with dev module

        # From modules/system/security/rtkit.nix (5 lines -> inlined)
        ({...}: {
          config = {
            security.rtkit.enable = true;
          };
        })

        # From modules/system/core/nix-ld.nix (5 lines -> inlined)
        ({...}: {
          config = {
            programs.nix-ld.enable = true;
          };
        })

        # From modules/system/hardware/i2c.nix (5 lines -> inlined)
        ({...}: {
          config = {
            hardware.i2c.enable = true;
          };
        })

        # From modules/system/networking/networkmanager.nix (5 lines -> inlined)
        ({...}: {
          config = {
            networking.networkmanager.enable = true;
          };
        })

        # 🔥 ROUND 2 OBLITERATION - MORE TINY MODULES DESTROYED! 🔥

        # From modules/system/core/ollama.nix (7 lines -> inlined)
        ({...}: {
          config = {
            services.ollama = {
              enable = true;
            };
          };
        })

        # From modules/system/hardware/video.nix (7 lines -> inlined)
        ({...}: {
          config = {
            services.udev.extraRules = ''
              KERNEL=="video[0-9]*", GROUP="video", MODE="0660"
            '';
          };
        })

        # From modules/system/core/nix-tools.nix (9 lines -> inlined)
        ({pkgs, ...}: {
          config = {
            environment.systemPackages = [
              pkgs.alejandra
              pkgs.statix
              pkgs.deadnix
            ];
          };
        })

        # 🔥 ROUND 3 OBLITERATION - MEDIUM MODULES ANNIHILATED! 🔥

        # From modules/system/services/scx.nix (9 lines -> inlined)
        # TEMPORARILY COMMENTED - ALREADY CONFIGURED VIA services module
        # ({pkgs, ...}: {
        #   config = {
        #     services.scx = {
        #       enable = true;
        #       scheduler = "scx_lavd";
        #       package = pkgs.scx.rustscheds;
        #     };
        #   };
        # })

        # From modules/home/gaming/shader-cache.nix (10 lines -> inlined)
        ({config, ...}: {
          config = {
            hjem.users.${config.user.name}.files.".config/steam/steam_dev.cfg" = {
              text = ''
                unShaderBackgroundProcessingThreads ${toString config.nix.settings.max-jobs}
              '';
              clobber = true;
            };
          };
        })

        # From modules/system/programs/obs.nix (10 lines -> inlined)
        ({config, ...}: {
          boot = {
            kernelModules = ["v4l2loopback"];
            extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
            extraModprobeConfig = ''
              options v4l2loopback exclusive_caps=1
            '';
          };
          # security.polkit.enable = true; # COMMENTED - already enabled above
        })

        # From modules/home/ui/hyprland/monitors.nix (9 lines -> inlined)
        # NOTE: This needs to be in hjem config, not system config
        # TEMPORARILY COMMENTED - needs proper hyprland integration
        # ({...}: {
        #   monitor = [
        #     "DP-4,highres@highrr,0x0,1"
        #     "DP-3,highres@highrr,0x0,1"
        #     "DP-2,5120x1440@239.76,0x0,1"
        #     "DP-1,5120x1440@239.76,0x0,1"
        #     "eDP-1,1920x1080@300.00,0x0,1"
        #   ];
        # })

        # Home manager integration
        (sources.hjem + "/modules/nixos")
        allModules.home.core
        allModules.home.dev
        allModules.home.gaming
        allModules.home.programs
        allModules.home.services
        allModules.home.shell
        allModules.home.tools

        # 🔥 OBLITERATED HOME DEFAULT.NIX WRAPPERS! 🔥

        # From modules/home/dev/nvim.nix (3 lines -> OBLITERATED)
        # TEMPORARILY COMMENTED - ALREADY IMPORTED VIA dev module
        # (import ./modules/home/dev/nvim)

        # From modules/home/core/fonts/default.nix (5 lines -> OBLITERATED)
        # TEMPORARILY COMMENTED - ALREADY IMPORTED VIA core module
        # (import ./modules/home/core/fonts/presets.nix)

        # From modules/home/core/session/default.nix (5 lines -> OBLITERATED)
        # TEMPORARILY COMMENTED - ALREADY IMPORTED VIA core module
        # (import ./modules/home/core/session/xdg.nix)

        # From modules/home/gaming/balatro/default.nix (5 lines -> OBLITERATED)
        # TEMPORARILY COMMENTED - ALREADY IMPORTED VIA gaming module
        # (import ./modules/home/gaming/balatro/installation.nix)

        # From modules/home/gaming/wukong/default.nix (5 lines -> OBLITERATED)
        # TEMPORARILY COMMENTED - ALREADY IMPORTED VIA gaming module
        # (import ./modules/home/gaming/wukong/engine.nix)

        # From modules/home/gaming/emulation/default.nix (6 lines -> OBLITERATED)
        # TEMPORARILY COMMENTED - ALREADY IMPORTED VIA gaming module
        # (import ./modules/home/gaming/emulation/cemu.nix)
        # (import ./modules/home/gaming/emulation/dolphin.nix)

        # From modules/home/ui/hyprland/default.nix (6 lines -> OBLITERATED)
        # TEMPORARILY COMMENTED - ALREADY IMPORTED VIA ui module
        # (import ./modules/home/ui/hyprland/options.nix)
        # (import ./modules/home/ui/hyprland/config.nix)
        # allModules.home.ui (commented out - wayland.nix inlined below)
        # Import individual UI modules except wayland.nix
        (import ./modules/home/ui/ags.nix)
        (import ./modules/home/ui/cursor.nix)
        (import ./modules/home/ui/fonts.nix)
        (import ./modules/home/ui/foot.nix)
        (import ./modules/home/ui/gtk.nix)
        (import ./modules/home/ui/hyprland)
        (import ./modules/home/ui/mako.nix)
        (import ./modules/home/ui/niri)
        (import ./modules/home/ui/qutebrowser.nix)
        (import ./modules/home/ui/quickshell.nix)
        (import ./modules/home/ui/wallust.nix)

        # From modules/home/ui/wayland.nix (31 lines -> inlined)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.ui.wayland;
        in {
          options.home.ui.wayland = {
            enable = lib.mkEnableOption "Wayland configuration";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name} = {
              packages = with pkgs; [
                grim
                slurp
                wl-clipboard
                hyprpicker
              ];
              files = {
                ".config/zsh/.zshenv" = {
                  text = lib.mkAfter ''
                    export WLR_NO_HARDWARE_CURSORS=1
                    export NIXOS_OZONE_WL=1
                    export QT_QPA_PLATFORM=wayland
                    export ELECTRON_OZONE_PLATFORM_HINT=wayland
                    export XDG_SESSION_TYPE=wayland
                    export GDK_BACKEND=wayland,x11
                    export SDL_VIDEODRIVER=wayland
                    export CLUTTER_BACKEND=wayland
                  '';
                  clobber = true;
                };
              };
            };
          };
        })

        # User configuration abstraction (inline from lib/user-config.nix)
        ({
          lib,
          config,
          ...
        }: {
          options = {
            user = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "Primary username for the system";
                example = "alice";
              };
              homeDirectory = lib.mkOption {
                type = lib.types.path;
                description = "Home directory path for the user";
                example = "/home/alice";
              };
              configDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/.config";
                description = "XDG config directory path";
              };
              dataDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/.local/share";
                description = "XDG data directory path";
              };
              stateDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/.local/state";
                description = "XDG state directory path";
              };
              cacheDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/.cache";
                description = "XDG cache directory path";
              };
              nixosConfigDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/nixos";
                description = "NixOS configuration directory";
              };
              tokensDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/Tokens";
                description = "Directory containing API tokens and secrets";
              };
            };
          };
          config = {
            assertions = [
              {
                assertion = config.user.name != "";
                message = "user.name must be set to a non-empty string";
              }
              {
                assertion = lib.hasPrefix "/" (toString config.user.homeDirectory);
                message = "user.homeDirectory must be an absolute path";
              }
            ];
          };
        })

        # Host-specific configuration
        ({
          config,
          lib,
          ...
        }: {
          inherit (hostConfig) imports;

          hostSystem = {
            inherit (hostConfig) users hostname homeDirectory stateVersion timezone;
            profile = hostConfig.profile or "default";
            hardware = hostConfig.hardware or {};
            services = hostConfig.services or {};
          };

          user = let
            primaryUser = builtins.head hostConfig.users;
          in {
            name = primaryUser;
            inherit (hostConfig) homeDirectory;
          };

          nixpkgs = {
            inherit overlays;
            config = {
              allowUnfree = true;
              cudaSupport = true;
            };
          };

          # Configure hjem for all users (simplified like original)
          hjem = {
            linker = pkgs.callPackage (sources.smfh + "/package.nix") {};
            users = lib.genAttrs users (_username: {
              packages = [];
              files = {};
            });
          };
        })
      ];

      _module.args = {
        inherit (hostConfig) hostname;
        inherit users sources;
        inherit (pkgs) lib;
        inherit hostConfig;
        userConfigs = hostUserConfigs;
        hostSystem = hostConfig;
        hostsDir = ./configs/hosts;
        inherit (sources) disko nix-minecraft Fast-Font;
      };
    };
  };
}
