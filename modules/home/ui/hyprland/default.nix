{...}: {
  imports = [
    ./config.nix
    ./core.nix
    ./integrations.nix
    ./keybindings.nix
    ./options.nix
    ./toHyprconf.nix
  ];
}
