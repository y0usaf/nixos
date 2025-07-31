let
  sources = import ./npins;
  system = "x86_64-linux";

  # Consolidated overlays from lib/overlays/
  overlays = [
    # neovim-nightly overlay
    (import (sources.neovim-nightly-overlay))

    # Fast Font overlay (from lib/overlays/fast-fonts.nix)
    (final: _prev: {
      fastFonts = final.stdenvNoCC.mkDerivation {
        pname = "fast-fonts";
        version = "1.0.0";
        src = sources.Fast-Font;

        installPhase = ''
          mkdir -p $out/share/fonts/truetype
          install -m444 -Dt $out/share/fonts/truetype *.ttf
          mkdir -p $out/share/doc/fast-fonts
          if [ -f LICENSE ]; then
            install -m444 -Dt $out/share/doc/fast-fonts LICENSE
          fi
          if [ -f README.md ]; then
            install -m444 -Dt $out/share/doc/fast-fonts README.md
          fi
        '';

        meta = with final.lib; {
          description = "Fast Font Collection - TTF fonts";
          longDescription = "Fast Font Collection provides optimized monospace and sans-serif fonts";
          homepage = "https://github.com/y0usaf/Fast-Font";
          platforms = platforms.all;
          license = licenses.mit;
        };
      };
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

  # LEGACY allModules structure removed - all functionality consolidated into default.nix!

  # User configurations
  userConfigs = {
    y0usaf = import ./configs/users/y0usaf {inherit pkgs lib;};
    guest = import ./configs/users/guest {inherit pkgs lib;};
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
        # Host system configuration (EXACTLY like original lib/default.nix structure)
        # From modules/system/core/system.nix (49 lines -> INLINED!)
        ({
          config,
          lib,
          ...
        }: {
          inherit (hostConfig) imports;
          options.hostSystem = {
            users = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = "System usernames";
            };
            username = lib.mkOption {
              type = lib.types.str;
              description = "Primary system username (derived from first user)";
              default = builtins.head config.hostSystem.users;
            };
            hostname = lib.mkOption {
              type = lib.types.str;
              description = "System hostname";
            };
            homeDirectory = lib.mkOption {
              type = lib.types.path;
              description = "Primary user home directory path";
            };
            stateVersion = lib.mkOption {
              type = lib.types.str;
              description = "NixOS state version for compatibility";
            };
            timezone = lib.mkOption {
              type = lib.types.str;
              description = "System timezone";
            };
            profile = lib.mkOption {
              type = lib.types.str;
              description = "Configuration profile identifier";
              default = "default";
            };
            hardware = lib.mkOption {
              type = lib.types.attrs;
              description = "Hardware configuration options";
              default = {};
            };
            services = lib.mkOption {
              type = lib.types.attrs;
              description = "System services configuration";
              default = {};
            };
          };
          config = {
            hostSystem = {
              inherit (hostConfig) users;
              inherit (hostConfig) hostname;
              inherit (hostConfig) homeDirectory;
              inherit (hostConfig) stateVersion;
              inherit (hostConfig) timezone;
              profile = hostConfig.profile or "default";
              hardware = hostConfig.hardware or {};
              services = hostConfig.services or {};
            };
            system.stateVersion = config.hostSystem.stateVersion;
            time.timeZone = config.hostSystem.timezone;
            networking.hostName = config.hostSystem.hostname;
            assertions = [
              {
                assertion = config.hostSystem.username != "";
                message = "System username cannot be empty";
              }
              {
                assertion = config.hostSystem.hostname != "";
                message = "System hostname cannot be empty";
              }
              {
                assertion = lib.hasPrefix "/" (toString config.hostSystem.homeDirectory);
                message = "Home directory must be an absolute path";
              }
            ];
            # Set user configuration from primary user
            user = let
              primaryUser = builtins.head hostConfig.users;
            in {
              name = primaryUser;
              inherit (hostConfig) homeDirectory;
            };
            # Configure nixpkgs with overlays
            nixpkgs = {
              inherit overlays;
              config = {
                allowUnfree = true;
                cudaSupport = true;
              };
            };
          };
        })
        # User home configurations via hjem (EXACTLY like original structure)
        ({
          config,
          lib,
          ...
        }: {
          imports = [
            # Use hjem for home management
            (sources.hjem + "/modules/nixos")
          ];
          config = {
            # Use proper NixOS module merging
            home = lib.mkMerge (
              lib.mapAttrsToList (
                _username: userConfig:
                # Remove system-specific config that doesn't belong in home
                  lib.filterAttrs (name: _: name != "system") userConfig
              )
              hostUserConfigs
            );
            # Configure hjem for each user
            hjem = {
              # Use SMFH manifest linker instead of systemd-tmpfiles
              linker = pkgs.callPackage (sources.smfh + "/package.nix") {};
              users = lib.genAttrs users (_username: {
                packages = [];
                files = {};
              });
            };
          };
        })
        # User configuration abstraction (from lib/user-config.nix - 95 lines -> INLINED!)
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
        # 🔥 EXPLODED HOME MODULES DIRECTORY - Individual imports for targeted inlining! 🔥

        # From modules/home/ui/default.nix (16 lines -> OBLITERATED!)
        (import ./modules/home/ui/ags.nix)
        (import ./modules/home/ui/cursor.nix)
        (import ./modules/home/ui/fonts.nix)
        (import ./modules/home/ui/foot.nix)
        (import ./modules/home/ui/gtk.nix)
        # From modules/home/ui/hyprland/default.nix (6 lines -> OBLITERATED!)
        (import ./modules/home/ui/hyprland/options.nix)
        (import ./modules/home/ui/hyprland/config.nix)
        (import ./modules/home/ui/mako.nix)
        # From modules/home/ui/niri/default.nix + options.nix inline (5+19 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.ui.niri;
        in {
          # From modules/home/ui/niri/options.nix (5 lines -> INLINED!)
          options.home.ui.niri = {
            enable = lib.mkEnableOption "Niri wayland compositor";
          };

          imports = [
            ./modules/home/ui/niri/config.nix
          ];

          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              xwayland-satellite
            ];
          };
        })
        (import ./modules/home/ui/qutebrowser.nix)
        (import ./modules/home/ui/wayland-tools.nix)

        # 🔥 CONSOLIDATED MODULE IMPORTS! 🔥
        (import ./modules/home/gaming.nix)
        (import ./modules/home/programs.nix)
        (import ./modules/home/services.nix)
        (import ./modules/home/shell.nix)
        (import ./modules/home/tools.nix)
        (import ./modules/home/core.nix)

        # Dev modules functionality now consolidated in dev.nix

        # 🔥 HARDWARE MODULES CONSOLIDATION! 🔥
        # From modules/system/hardware/nvidia.nix (62 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          hostSystem,
          ...
        }: {
          config = lib.mkIf hostSystem.hardware.nvidia.enable {
            boot.kernelParams = [
              "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
            ];
            hardware.nvidia = {
              modesetting.enable = true;
              powerManagement.enable = true;
              open = false;
              nvidiaSettings = true;
              package = config.boot.kernelPackages.nvidiaPackages.stable;
            };
            hardware.graphics.extraPackages = lib.optionals (hostSystem.hardware.nvidia.cuda.enable or false) [
              pkgs.cudatoolkit
            ];
            environment = {
              systemPackages = lib.optionals (hostSystem.hardware.nvidia.cuda.enable or false) [
                pkgs.cudaPackages.cudnn
              ];
              etc = {
                "nvidia/nvidia-application-profiles-rc".text = lib.mkForce ''
                  {
                    "rules": [
                      {
                        "pattern": {
                          "feature": "procname",
                          "matches": ".Hyprland-wrapped"
                        },
                        "profile": "No VidMem Reuse"
                      },
                      {
                        "pattern": {
                          "feature": "procname",
                          "matches": "electron"
                        },
                        "profile": "No VidMem Reuse"
                      },
                      {
                        "pattern": {
                          "feature": "procname",
                          "matches": ".firefox-wrapped"
                        },
                        "profile": "No VidMem Reuse"
                      },
                      {
                        "pattern": {
                          "feature": "procname",
                          "matches": "firefox"
                        },
                        "profile": "No VidMem Reuse"
                      }
                    ]
                  }
                '';
              };
              variables = {
                GBM_BACKEND = "nvidia-drm";
                LIBVA_DRIVER_NAME = "nvidia";
                WLR_NO_HARDWARE_CURSORS = "1";
                __GLX_VENDOR_LIBRARY_NAME = "nvidia";
                NVIDIA_DRIVER_CAPABILITIES = "all";
                WAYDROID_EXTRA_ARGS = "--gpu-mode host";
                GALLIUM_DRIVER = "nvidia";
                LIBGL_DRIVER_NAME = "nvidia";
              };
            };
            services.xserver.videoDrivers = ["nvidia"];
            security.polkit.extraConfig = ''
              polkit.addRule(function(action, subject) {
                if (action.id == "org.freedesktop.policykit.exec" &&
                    action.lookup("command_line").indexOf("nvidia-smi") >= 0) {
                    return polkit.Result.YES;
                }
              });
            '';
          };
        })

        # From modules/system/hardware/default.nix (consolidated hardware modules - 95 lines -> INLINED!)
        # AMD GPU support (9 lines -> INLINED!)
        ({
          lib,
          hostSystem,
          ...
        }: {
          config = {
            services.xserver.videoDrivers = lib.mkIf hostSystem.hardware.amdgpu.enable ["amdgpu"];
          };
        })

        # Bluetooth support (27 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          hostSystem,
          ...
        }: let
          hardwareCfg = hostSystem.hardware;
        in {
          config = {
            hardware.bluetooth = lib.mkIf (hardwareCfg.bluetooth.enable or false) {
              enable = true;
              powerOnBoot = true;
              settings =
                hardwareCfg.bluetooth.settings or {
                  General = {
                    ControllerMode = "dual";
                    FastConnectable = true;
                  };
                };
              package = pkgs.bluez;
            };
            services.dbus.packages = lib.mkIf (hardwareCfg.bluetooth.enable or false) [pkgs.bluez];
            environment.systemPackages = lib.optionals (hardwareCfg.bluetooth.enable or false) [pkgs.bluez pkgs.bluez-tools];
            users.users.${config.hostSystem.username}.extraGroups = lib.optionals (hardwareCfg.bluetooth.enable or false) ["dialout" "bluetooth" "lp"];
          };
        })

        # Graphics support (12 lines -> INLINED!)
        ({pkgs, ...}: {
          config = {
            hardware.graphics = {
              enable = true;
              enable32Bit = true;
              extraPackages = [pkgs.vaapiVdpau pkgs.libvdpau-va-gl];
            };
          };
        })

        # I2C support (3 lines -> INLINED!)
        (_: {
          config = {
            hardware.i2c.enable = true;
          };
        })

        # Input devices support (19 lines -> INLINED!)
        ({
          lib,
          hostSystem,
          ...
        }: {
          config = {
            services.udev.extraRules = lib.mkMerge [
              ''
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users"
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", TAG+="uaccess"
              ''
              (lib.mkIf (hostSystem.services.controllers.enable or false) ''
                KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
                KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"
                KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", TAG+="uaccess"
              '')
            ];
          };
        })

        # Video devices support (7 lines -> INLINED!)
        (_: {
          config = {
            services.udev.extraRules = ''KERNEL=="video[0-9]*", GROUP="video", MODE="0660"'';
          };
        })

        # 🔥 FINAL WRAPPER MODULE OBLITERATION! 🔥
        # balatro/installation.nix consolidated into gaming.nix
        # From modules/home/gaming/emulation/default.nix (6 lines -> OBLITERATED!)
        # emulation modules consolidated into gaming.nix
        # marvel-rivals modules consolidated elsewhere
        # From modules/home/gaming/wukong/default.nix (5 lines -> OBLITERATED!)
        # wukong module consolidated into gaming.nix

        # From modules/home/programs/default.nix (21 lines -> OBLITERATED!)
        # android.nix consolidated into programs.nix
        # bambu.nix consolidated into programs.nix
        # From modules/home/programs/bluetooth.nix (24 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.programs.bluetooth;
        in {
          options.home.programs.bluetooth = {
            enable = lib.mkEnableOption "Bluetooth user tools";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name} = {
              packages = with pkgs; [
                blueman
                bluetuith
              ];
              files.".config/autostart/blueman.desktop" = {
                clobber = true;
                source = "${pkgs.blueman}/etc/xdg/autostart/blueman.desktop";
              };
            };
          };
        })
        # From modules/home/programs/creative.nix (18 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.programs.creative;
        in {
          options.home.programs.creative = {
            enable = lib.mkEnableOption "creative applications module";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              pinta
              gimp
            ];
          };
        })
        # discord.nix consolidated into programs.nix
        # From modules/home/programs/imv.nix (15 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.programs.imv;
        in {
          options.home.programs.imv = {
            enable = lib.mkEnableOption "imv image viewer";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [imv];
          };
        })
        # From modules/home/programs/media.nix (21 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.programs.media;
        in {
          options.home.programs.media = {
            enable = lib.mkEnableOption "media applications";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              pavucontrol
              ffmpeg
              vlc
              stremio
              cmus
            ];
          };
        })
        # From modules/home/programs/mpv.nix (15 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.programs.mpv;
        in {
          options.home.programs.mpv = {
            enable = lib.mkEnableOption "mpv media player";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [mpv];
          };
        })
        # obs.nix consolidated into programs.nix
        # obsidian.nix consolidated into programs.nix
        # From modules/home/programs/pcmanfm.nix (17 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.programs.pcmanfm;
        in {
          options.home.programs.pcmanfm = {
            enable = lib.mkEnableOption "pcmanfm file manager";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              pcmanfm
            ];
          };
        })
        # From modules/home/programs/qbittorrent.nix (17 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.programs.qbittorrent;
        in {
          options.home.programs.qbittorrent = {
            enable = lib.mkEnableOption "qBittorrent torrent client";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              qbittorrent
            ];
          };
        })
        # From modules/home/programs/stremio.nix (15 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.programs.stremio;
        in {
          options.home.programs.stremio = {
            enable = lib.mkEnableOption "Stremio media center";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [stremio];
          };
        })
        # sway-launcher-desktop.nix consolidated into programs.nix
        # From modules/home/programs/vesktop.nix (15 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.programs.vesktop;
        in {
          options.home.programs.vesktop = {
            enable = lib.mkEnableOption "Vesktop (Discord client) module";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = [pkgs.vesktop];
          };
        })
        # webapps.nix consolidated into programs.nix
        # Firefox modules consolidated into programs.nix

        # 🔥 MORE WRAPPER MODULES OBLITERATED! 🔥

        # From modules/home/core/default.nix (11 lines -> OBLITERATED!)
        # appearance.nix INLINED ABOVE! ☝️
        # defaults.nix INLINED ABOVE! ☝️
        # directories.nix INLINED ABOVE! ☝️
        # packages.nix INLINED ABOVE! ☝️
        # user.nix INLINED ABOVE! ☝️
        # Session modules consolidated elsewhere
        # From modules/home/core/fonts/default.nix (5 lines -> OBLITERATED!)
        # fonts-presets.nix INLINED ABOVE! ☝️

        # Dev modules consolidated into single dev.nix file
        (import ./modules/home/dev.nix)

        # 🔥 OBLITERATED WRAPPER MODULES! 🔥

        # Shell modules consolidated into shell.nix

        # From modules/home/tools/default.nix (12 lines -> OBLITERATED!)
        # From modules/home/tools/7z.nix (17 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.tools."7z";
        in {
          options.home.tools."7z" = {
            enable = lib.mkEnableOption "7z (p7zip) archive manager";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              p7zip
            ];
          };
        })
        # From modules/home/tools/file-roller.nix (17 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.tools.file-roller;
        in {
          options.home.tools.file-roller = {
            enable = lib.mkEnableOption "file-roller (archive manager)";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              file-roller
            ];
          };
        })
        # Tools modules consolidated into tools.nix

        # Services modules consolidated into services.nix
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
