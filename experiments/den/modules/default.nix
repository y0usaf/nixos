{inputs, ...}: {
  imports = [
    inputs.den.flakeModule
    ./schema.nix
    ./hosts.nix
    ./aspects/shared.nix
    ./aspects/hosts.nix
    ./aspects/users.nix
  ];
}
