{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.dev.nvim;
  username = config.user.name;
in {
  config = lib.mkIf (cfg.enable && cfg.neovide) {
    hjem.users.${config.user.name} = {
      packages = with pkgs; [
        neovide
      ];
      files.".config/neovide/config.toml".text = ''
        [font]
        normal = ["Fast_Mono"]
        size = 14.0
        [window]
        transparency = 0.9
        [input]
        ime = true
      '';
    };
  };
}
