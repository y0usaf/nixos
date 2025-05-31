#═══════════════════════════ 🔧 PACKAGES MODULE 🔧 ═══════════════════════════#
{
  config,
  lib,
  pkgs,
  hostHome,
  ...
}: let
  helpers = import ../../lib/helpers/module-defs.nix {inherit lib;};
  inherit (helpers) mkOpt defaultAppModule;

  # Base packages all users should have
  basePackages = with pkgs; [
    # Essential CLI tools
    git
    curl
    wget
    cachix
    unzip
    bash
    vim # Or replace with hostHome.cfg.defaults.editor.package if defined
    lsd
    alejandra
    tree
    bottom
    psmisc

    # System interaction
    dconf # Already here, needed for dconf.enable
    lm_sensors
    networkmanager # Might be needed for applets/widgets
  ];

  # Final list includes base and explicit user packages (no userPackages from defaults)
  finalPackages = basePackages ++ (hostHome.cfg.user.packages or []);
in {
  # Default applications options
  options.cfg.defaults = {
    browser = mkOpt defaultAppModule "Default web browser configuration.";
    editor = mkOpt defaultAppModule "Default text editor configuration.";
    ide = mkOpt defaultAppModule "Default IDE configuration.";
    terminal = mkOpt defaultAppModule "Default terminal emulator configuration.";
    fileManager = mkOpt defaultAppModule "Default file manager configuration.";
    launcher = mkOpt defaultAppModule "Default application launcher configuration.";
    discord = mkOpt defaultAppModule "Default Discord client configuration.";
    archiveManager = mkOpt defaultAppModule "Default archive manager configuration.";
    imageViewer = mkOpt defaultAppModule "Default image viewer configuration.";
    mediaPlayer = mkOpt defaultAppModule "Default media player configuration.";
  };

  # Set the home packages
  config.home.packages = finalPackages;

  # Enable dconf
  config.dconf.enable = true;
}
