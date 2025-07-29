{...}: {
  imports = [
    ./cachix.nix
    ./lix.nix
    # nix-ld.nix (3 lines -> INLINED!)
    (_: {config = {programs.nix-ld.enable = true;};})
    ./nix-package-management.nix
    # nix-tools.nix (9 lines -> INLINED!)
    ({pkgs, ...}: {config = {environment.systemPackages = [pkgs.alejandra pkgs.statix pkgs.deadnix];};})
    # ollama.nix (7 lines -> INLINED!) - NOW OPTIONAL
    ({
      lib,
      hostSystem,
      ...
    }: {config = {services.ollama = lib.mkIf (hostSystem.services.ollama.enable or false) {enable = true;};};})
    ./system.nix
  ];
}
