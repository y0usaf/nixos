###############################################################################
# Flake Utilities
# Host configuration utilities and helper functions
###############################################################################
{
  lib,
  pkgs,
  helpers,
  ...
}: let
  # Import individual modules
  shared = import ./shared.nix {inherit lib pkgs helpers;};
  system = import ./system.nix {inherit lib pkgs helpers;};
in {
  # Export configuration functions
  inherit (shared) hostNames systemConfigs homeConfigs mkSpecialArgs;
  inherit (system) mkNixosConfigurations;
}
