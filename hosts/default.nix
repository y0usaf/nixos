###############################################################################
# NixOS System Configuration
# Complete system configuration through modular imports
# All configuration details are defined in the modules/system directory
###############################################################################
{
  # The following variables are injected by the NixOS module system:
  #   - config: The cumulative system configuration.
  #   - lib: Library functions for list manipulation, options handling, etc.
  #   - pkgs: The collection of available Nix packages.
  #   - host: A user-defined host specifying many system preferences.
  #   - inputs: External inputs (like additional packages or modules).
  #   - ...: Any extra parameters.
  config,
  lib,
  pkgs,
  host,
  inputs,
  ...
}: {
  ###########################################################################
  # Module Imports
  # Import all system configuration modules
  ###########################################################################
  imports = [
    # Core system modules - imports all modules from the system directory
    ../modules/system
  ];
}
