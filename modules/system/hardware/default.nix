{...}: {
  imports = [
    ./amd.nix
    ./bluetooth.nix
    ./graphics.nix
    # i2c.nix (3 lines -> INLINED!)
    (_: {config = {hardware.i2c.enable = true;};})
    ./input.nix
    ./nvidia.nix
    ./video.nix
  ];
}
