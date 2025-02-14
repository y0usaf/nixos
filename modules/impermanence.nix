{ config, lib, pkgs, inputs, profile, ... }: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  home.persistence."/persist/home/${profile.username}" = {
    directories = [
      # Your critical directories
      "nixos"
      "Music"
      "DCIM"
      "Pictures"
      "Dev"
      ".local/share/Steam"
      # Add configuration directories
      ".config/nixos"
      ".ssh"
      ".gnupg"
      # Add state directories
      ".local/state/zsh"  # For zsh history
    ];
    files = [
      # Important dotfiles
      ".gitconfig"
      # Add other specific files you want to persist
    ];
    allowOther = true;  # Allows other users to access persistent files
  };
} 