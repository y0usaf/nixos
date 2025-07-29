{
  description = "Minimal flake wrapper for npins-based NixOS configuration";

  # No inputs - everything comes from npins
  inputs = {};

  outputs = _: let
    config = import ./default.nix;
  in {
    # Just expose our npins-based nixosConfigurations
    inherit (config) nixosConfigurations;

    # Expose formatter for flake check compatibility
    formatter.x86_64-linux = config.formatter.x86_64-linux;

    # Expose the lib
    inherit (config) lib;
  };
}
