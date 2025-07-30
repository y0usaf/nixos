{...}: {
  imports = [
    # cachix.nix (22 lines -> INLINED!)
    {
      config = {
        nix.settings = {
          substituters = [
            "https://hyprland.cachix.org"
            "https://chaotic-nyx.cachix.org"
            "https://nyx.cachix.org"
            "https://cuda-maintainers.cachix.org"
            "https://nix-community.cachix.org"
            "https://nix-gaming.cachix.org"
          ];
          trusted-public-keys = [
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
            "nyx.cachix.org-1:xH6G0MO9PrpeGe7mHBtj1WbNzmnXr7jId2mCiq6hipE="
            "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
          ];
        };
      };
    }
    # lix.nix (11 lines -> INLINED!)
    ({
      config,
      lib,
      pkgs,
      ...
    }: {
      options.programs.lix.enable = lib.mkEnableOption "whether to enable lix package";
      config = lib.mkIf config.programs.lix.enable {
        nix.package = pkgs.lix;
      };
    })
    # nix-ld.nix (3 lines -> INLINED!)
    (_: {config = {programs.nix-ld.enable = true;};})
    # nix-package-management.nix (28 lines -> INLINED!)
    ({
      config,
      pkgs,
      ...
    }: {
      config = {
        nix = {
          package = pkgs.nixVersions.stable;
          settings = {
            auto-optimise-store = true;
            max-jobs = "auto";
            cores = 0;
            experimental-features = ["nix-command" "flakes"];
            sandbox = true;
            trusted-users = ["root" config.hostSystem.username];
            builders-use-substitutes = true;
            fallback = true;
            substituters = [
              "https://cache.nixos.org"
            ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            ];
          };
          extraOptions = "";
        };
      };
    })
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
