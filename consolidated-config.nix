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
        # Import user configuration abstraction
        ./lib/user-config.nix
        # Import home manager modules (EXACTLY like original)
        ./modules/home
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
