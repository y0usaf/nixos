# 02: flake-parts Architecture

## flake.nix (Minimal)

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # ... all inputs
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [ ./modules/flake ];
    };
}
```

## modules/flake/default.nix

```nix
{
  imports = [
    ./nixos.nix
    ./darwin.nix
    ./overlays.nix
    ./formatter.nix
    ../dev
    ../shell
    ../system
    ../user
    ../services
  ];
}
```

## modules/flake/nixos.nix

```nix
{ config, inputs, ... }:
let
  allModules = builtins.attrValues config.flake.nixosModules;

  mkHost = { hostName, system ? "x86_64-linux", hostModule }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs hostName; };
      modules = allModules ++ [
        hostModule
        inputs.hjem.nixosModules.default
        inputs.nvf.nixosModules.default
      ];
    };
in {
  flake.nixosConfigurations = {
    y0usaf-desktop = mkHost {
      hostName = "y0usaf-desktop";
      hostModule = ../hosts/y0usaf-desktop.nix;
    };
    # ... other hosts
  };
}
```

## Feature Module Pattern

```nix
# modules/dev/nvim.nix
{ lib, ... }: {
  flake.nixosModules.nvim = { config, pkgs, ... }: {
    options.cfg.programs.nvim.enable = lib.mkEnableOption "neovim";
    config = lib.mkIf config.cfg.programs.nvim.enable {
      environment.systemPackages = [ pkgs.neovim ];
    };
  };

  flake.darwinModules.nvim = { config, pkgs, ... }: {
    options.cfg.programs.nvim.enable = lib.mkEnableOption "neovim";
    config = lib.mkIf config.cfg.programs.nvim.enable {
      environment.systemPackages = [ pkgs.neovim ];
    };
  };
}
```

## Host Pattern

```nix
# modules/hosts/y0usaf-desktop.nix
{ ... }: {
  imports = [ ./y0usaf-desktop/hardware-configuration.nix ];

  cfg.programs.nvim.enable = true;
  cfg.hardware.nvidia.enable = true;
  cfg.user.gaming.enable = true;

  networking.hostName = "y0usaf-desktop";
  system.stateVersion = "24.11";
}
```

## How It Works

1. `flake.nix` imports `modules/flake/`
2. `modules/flake/default.nix` imports all feature modules
3. Feature modules add to `config.flake.nixosModules.*`
4. `nixos.nix` collects all modules: `builtins.attrValues config.flake.nixosModules`
5. Each host gets ALL modules, enables features via `cfg.*.enable`

## modules/flake/overlays.nix

```nix
{ inputs, ... }: {
  flake.overlays.default = final: prev: {
    niri = inputs.niri.packages.${prev.system}.default;
  };
}
```

## modules/flake/formatter.nix

```nix
{ ... }: {
  perSystem = { pkgs, ... }: {
    formatter = pkgs.alejandra;
  };
}
```
