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
        # Host system configuration (EXACTLY like original lib/default.nix structure)
        ({config, ...}: {
          inherit (hostConfig) imports;
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
        (import ./modules/home/ui/hyprland)
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
        (import ./modules/home/ui/quickshell.nix)
        (import ./modules/home/ui/wallust.nix)
        (import ./modules/home/ui/wayland.nix)

        # 🔥 FINAL WRAPPER MODULE OBLITERATION! 🔥

        # From modules/home/gaming/default.nix (11 lines -> OBLITERATED!)
        (import ./modules/home/gaming/controllers.nix)
        (import ./modules/home/gaming/core.nix)
        (import ./modules/home/gaming/shader-cache.nix)
        # From modules/home/gaming/balatro/default.nix (5 lines -> OBLITERATED!)
        (import ./modules/home/gaming/balatro/installation.nix)
        # From modules/home/gaming/emulation/default.nix (6 lines -> OBLITERATED!)
        (import ./modules/home/gaming/emulation/cemu.nix)
        (import ./modules/home/gaming/emulation/dolphin.nix)
        (import ./modules/home/gaming/marvel-rivals)
        # From modules/home/gaming/wukong/default.nix (5 lines -> OBLITERATED!)
        (import ./modules/home/gaming/wukong/engine.nix)

        # From modules/home/programs/default.nix (21 lines -> OBLITERATED!)
        (import ./modules/home/programs/android.nix)
        (import ./modules/home/programs/bambu.nix)
        (import ./modules/home/programs/bluetooth.nix)
        (import ./modules/home/programs/creative.nix)
        (import ./modules/home/programs/discord.nix)
        (import ./modules/home/programs/imv.nix)
        (import ./modules/home/programs/media.nix)
        (import ./modules/home/programs/mpv.nix)
        (import ./modules/home/programs/obs.nix)
        (import ./modules/home/programs/obsidian.nix)
        (import ./modules/home/programs/pcmanfm.nix)
        (import ./modules/home/programs/qbittorrent.nix)
        (import ./modules/home/programs/stremio.nix)
        (import ./modules/home/programs/sway-launcher-desktop.nix)
        (import ./modules/home/programs/vesktop.nix)
        (import ./modules/home/programs/webapps.nix)
        (import ./modules/home/programs/firefox)

        # 🔥 MORE WRAPPER MODULES OBLITERATED! 🔥

        # From modules/home/core/default.nix (11 lines -> OBLITERATED!)
        (import ./modules/home/core/appearance.nix)
        (import ./modules/home/core/defaults.nix)
        (import ./modules/home/core/directories.nix)
        (import ./modules/home/core/packages.nix)
        (import ./modules/home/core/user.nix)
        # From modules/home/core/session/default.nix (5 lines -> OBLITERATED!)
        (import ./modules/home/core/session/xdg.nix)
        # From modules/home/core/fonts/default.nix (5 lines -> OBLITERATED!)
        (import ./modules/home/core/fonts/presets.nix)

        # From modules/home/dev/default.nix (13 lines -> OBLITERATED!)
        (import ./modules/home/dev/ai-tools)
        (import ./modules/home/dev/cursor-ide.nix)
        (import ./modules/home/dev/docker.nix)
        (import ./modules/home/dev/latex.nix)
        (import ./modules/home/dev/npm.nix)
        # From modules/home/dev/nvim.nix (3 lines -> OBLITERATED!)
        # From modules/home/dev/nvim/default.nix (9 lines -> OBLITERATED!)
        (import ./modules/home/dev/nvim/neovide.nix)
        # From modules/home/dev/nvim/options.nix (6 lines -> INLINED!)
        ({lib, ...}: {
          options.home.dev.nvim = {
            enable = lib.mkEnableOption "Enhanced Neovim with MNW wrapper";
            neovide = lib.mkEnableOption "Neovide GUI for Neovim";
          };
        })
        (import ./modules/home/dev/nvim/packages.nix)
        (import ./modules/home/dev/nvim/settings.nix)
        (import ./modules/home/dev/nvim/vim-pack.nix)
        (import ./modules/home/dev/python.nix)
        (import ./modules/home/dev/repomix.nix)
        (import ./modules/home/dev/upscale.nix)

        # 🔥 OBLITERATED WRAPPER MODULES! 🔥

        # From modules/home/shell/default.nix (8 lines -> OBLITERATED!)
        (import ./modules/home/shell/aliases.nix)
        (import ./modules/home/shell/cat-fetch.nix)
        (import ./modules/home/shell/zellij.nix)
        (import ./modules/home/shell/zsh.nix)

        # From modules/home/tools/default.nix (12 lines -> OBLITERATED!)
        (import ./modules/home/tools/7z.nix)
        (import ./modules/home/tools/file-roller.nix)
        (import ./modules/home/tools/git.nix)
        (import ./modules/home/tools/jj.nix)
        (import ./modules/home/tools/nh.nix)
        (import ./modules/home/tools/npins-build.nix)
        (import ./modules/home/tools/spotdl.nix)
        (import ./modules/home/tools/yt-dlp.nix)

        # From modules/home/services/default.nix (10 lines -> OBLITERATED!)
        (import ./modules/home/services/format-nix.nix)
        (import ./modules/home/services/hyprland-config-watcher.nix)
        (import ./modules/home/services/nixos-git-sync.nix)
        (import ./modules/home/services/polkit-agent.nix)
        (import ./modules/home/services/polkit-gnome.nix)
        (import ./modules/home/services/ssh.nix)
        (import ./modules/home/services/syncthing.nix)
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
