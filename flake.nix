{
  description = "Minimal flake wrapper for npins-based NixOS configuration";

  # No inputs - everything comes from npins
  inputs = {};

  outputs = _: let
    consolidated-config = import ./consolidated-config.nix;
  in {
    # Just expose our npins-based nixosConfigurations
    inherit (consolidated-config) nixosConfigurations;

    # Expose formatter for flake check compatibility
    formatter.x86_64-linux = consolidated-config.formatter.x86_64-linux;

    # Expose the lib
    inherit (consolidated-config) lib;
  };
}
