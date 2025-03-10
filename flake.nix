###############################################################################
# NixOS Flake Configuration
# System configuration and dependencies management for desktop environment
# - Manages system dependencies and configurations
# - Supports dynamic profile loading
# - Configures desktop environment for development and daily use
###############################################################################
{
  description = "NixOS configuration";

  ###########################################################################
  # Input Sources
  ###########################################################################
  inputs = {
    ## Core System Dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Add flake-utils
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Desktop Environment & Theming
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hy3 = {
      url = "github:outfoxxed/hy3";
      inputs.hyprland.follows = "hyprland";
    };

    deepin-dark-hyprcursor.url = "path:/home/y0usaf/nixos/pkg/deepin-dark-hyprcursor";
    deepin-dark-xcursor.url = "path:/home/y0usaf/nixos/pkg/deepin-dark-xcursor";

    hyprpaper = {
      url = "github:y0usaf/hyprpaper/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Development & Creative Tools
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };

    obs-image-reaction.url = "github:L-Nafaryus/obs-image-reaction";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Claude Desktop for Linux
    claude-desktop.url = "github:k3d3/claude-desktop-linux-flake";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";
    claude-desktop.inputs.flake-utils.follows = "flake-utils";

    # Whisper Overlay - Speech-to-text for Wayland
    whisper-overlay = {
      url = "github:oddlama/whisper-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  ###########################################################################
  # System Outputs
  ###########################################################################
  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    ## System & Package Configuration
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (final: prev: {
          inherit (inputs.uv2nix.packages.${system}) uv2nix;
          inherit (inputs.whisper-overlay.packages.${system}) whisper-overlay;
        })
      ];
      config.allowUnfree = true;
    };

    ## Dynamic Profile Loading
    profilesDir = ./profiles;
    profileNames = builtins.filter (
      name:
        name
        != "README.md"
        && name != "configurations"
        && name != "options.nix"
        && builtins.pathExists (profilesDir + "/${name}/default.nix")
    ) (builtins.attrNames (builtins.readDir profilesDir));

    # Import all available profiles dynamically
    profiles = builtins.listToAttrs (
      map
      (name: {
        inherit name;
        value = import (profilesDir + "/${name}") {
          lib = pkgs.lib;
          inherit pkgs;
        };
      })
      profileNames
    );

    ## Common Special Arguments for Modules
    commonSpecialArgs = {inputs = self.inputs;};
  in {
    ## Formatter Setup
    formatter.${system} = pkgs.alejandra;

    ## NixOS Configurations
    nixosConfigurations = builtins.listToAttrs (
      map
      (hostname: {
        name = hostname;
        value = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = commonSpecialArgs // {profile = profiles.${hostname};};
          modules = [
            (profilesDir + "/${hostname}/configuration.nix")
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = commonSpecialArgs // {profile = profiles.${hostname};};
                users.${profiles.${hostname}.username} = {
                  imports = [./home.nix];
                  home = {
                    stateVersion = profiles.${hostname}.stateVersion;
                    homeDirectory = nixpkgs.lib.mkForce profiles.${hostname}.homeDirectory;
                  };
                };
              };
            }
            inputs.chaotic.nixosModules.default
            inputs.whisper-overlay.nixosModules.default
          ];
        };
      })
      profileNames
    );

    ## Dynamic Home Manager Configurations
    homeConfigurations = builtins.listToAttrs (
      map
      (hostname: let
        profileConfig = import (profilesDir + "/${hostname}/default.nix") {
          lib = pkgs.lib;
          inherit pkgs;
        };
      in {
        name = profileConfig.username;
        value = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = commonSpecialArgs // {profile = profileConfig;};
          modules = [
            ./home.nix
            inputs.whisper-overlay.homeManagerModules.default
          ];
        };
      })
      profileNames
    );
  };
}
