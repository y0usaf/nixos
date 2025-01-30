#─────────────────────── ❄️  NIXOS FLAKE CONFIG ───────────────────────#
# 🔄 System configuration and dependencies management                   #
# 🎯 Target: Desktop Environment for Development and Daily Use         #
#──────────────────────────────────────────────────────────────────────#
{
  description = "NixOS configuration";

  #── 📦 Input Sources & Dependencies ─────────────────────────────────#
  inputs = {
    #── 🎯 Core System Dependencies ──────────────────────────────────#
    # 📚 Main nixpkgs repository - using unstable channel
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # 🏠 Home Manager for user environment management
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ✨ Nix code formatter
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #── 🪟 Desktop Environment & Theming ────────────────────────────#
    # 🖥️ Hyprland Wayland compositor
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 📐 Hy3 - Hyprland tiling layout plugin
    hy3 = {
      url = "github:outfoxxed/hy3";
      inputs.hyprland.follows = "hyprland";
    };
    # 🖱️ Custom cursor themes
    deepin-dark-hyprcursor.url = "path:/home/y0usaf/nixos/pkg/deepin-dark-hyprcursor";
    deepin-dark-xcursor.url = "path:/home/y0usaf/nixos/pkg/deepin-dark-xcursor";

    #── 🛠️ Development & Creative Tools ─────────────────────────────#
    # 🐍 Python project management tools
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 🚀 Fast Python package installer
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 🎥 OBS Studio plugin for image reactions
    obs-image-reaction.url = "github:L-Nafaryus/obs-image-reaction";
    # 🎁 Additional package repository
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  #── ⚙️ System Configuration Builder ──────────────────────────────────#
  outputs = {
    self,
    nixpkgs,
    home-manager,
    obs-image-reaction,
    hyprland,
    alejandra,
    hy3,
    chaotic,
    ...
  } @ inputs: let
    # 💻 System architecture definition
    system = "x86_64-linux";
    # 📝 Configure nixpkgs with system and allow unfree packages
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    # 🌍 Import global variables
    globals = import ./globals.nix;

    #── 🏗️ Home Manager Configuration Builder ────────────────────────#
    # 🔨 Function to create consistent home-manager configurations
    mkHomeConfiguration = username: system:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
          globals = import ./globals.nix;
        };
        modules = [./home.nix];
      };
  in {
    #── 🎨 System Styling ───────────────────────────────────────────#
    formatter.${system} = pkgs.alejandra;

    #── 👤 User Environment Setup ──────────────────────────────────#
    homeConfigurations.${globals.username} = mkHomeConfiguration globals.username system;

    #── 🖥️ Machine-Specific Configuration ──────────────────────────#
    nixosConfigurations."y0usaf-desktop" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        globals = import ./globals.nix;
      };
      modules = [
        # 📋 Main system configuration
        ./configuration.nix
        # 🏠 Home-manager integration
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = {
              inherit inputs;
              hostName = "y0usaf-desktop";
              globals = import ./globals.nix;
            };
            # 👤 User-specific configuration
            users.y0usaf = import ./home.nix;
            # 🔄 Global package management
            useGlobalPkgs = true;
            useUserPackages = true;
            # 💾 Backup configuration
            backupFileExtension = "backup";
          };
        }
        # 📦 Additional package repository
        chaotic.nixosModules.default
      ];
    };
  };
}
