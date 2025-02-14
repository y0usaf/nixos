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
      "Music"
      "DCIM"
      "Pictures"
      "Dev"
      "Tokens"
      ".local/share/Steam"
      # Configuration directories
      ".config/nixos"
      ".ssh"
      ".gnupg"
      # State directories
      ".local/state/zsh" # For zsh history
      # Extra directories
      "Documents"
      "Videos"
      "Downloads"
      # Firefox profiles (adjust as needed)
      ".mozilla/firefox"
      # Your cursor configurations 
      ".cursor"           # for ~/.cursor
      ".config/Cursor"    # for ~/.config/Cursor
    ];
    files = [
      # Important dotfiles
      ".gitconfig"
      # Add other specific files you want to persist
    ];
    allowOther = true; # Allows other users to access persistent files
  };
}
