{...}: {
  imports = [
    ./cachix.nix
    ./lix.nix
    # nix-ld.nix (3 lines -> INLINED!)
    (_: {config = {programs.nix-ld.enable = true;};})
    ./nix-package-management.nix
    ./nix-tools.nix
    ./system.nix
  ];
}
