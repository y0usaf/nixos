{
  description = "Minimal flake wrapper for npins-based NixOS configuration";

  # Minimal inputs for git hooks
  inputs = {
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: let
    config = import ./default.nix {inherit inputs;};
  in {
    # Just expose our npins-based nixosConfigurations
    inherit (config) nixosConfigurations;

    # Expose formatter for flake check compatibility
    formatter.x86_64-linux = config.formatter.x86_64-linux;

    # Expose the lib
    inherit (config) lib;

    # Expose git hooks checks
    checks.x86_64-linux = config.checks.x86_64-linux or {};
  };
}
