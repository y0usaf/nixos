{
  config,
  lib,
  pkgs,
  inputs,
  profile,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  home.persistence."/persist/home/${profile.username}" = {
    directories = [
      # Your critical directories
      "nixos"
      "Dev"
      "Tokens"
      # Configuration directories
      ".ssh"
      ".gnupg"
      # State directories
      ".local/state/zsh" # For zsh history
      # Extra directories
      "Documents"
      "Videos"
      "Downloads"
      # Firefox profiles
      ".mozilla/firefox"
      # Your cursor configurations
      ".cursor" # for ~/.cursor
      ".config/Cursor" # for ~/.config/Cursor
    ];
    files = [
      # Important dotfiles
      ".gitconfig"
      # Add other specific files you want to persist
    ];
  };
}
