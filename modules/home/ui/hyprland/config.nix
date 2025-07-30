{
  config,
  pkgs,
  lib,
  inputs,
  hostSystem,
  ...
}: let
  cfg = config.home.ui.hyprland;
  inherit (config.home.core) defaults;
  generators = import ./generators/toHyprconf.nix lib;
  coreConfig = import ./core.nix {inherit config lib hostSystem cfg;};
  keybindingsConfig = import ./keybindings.nix {inherit lib config defaults cfg;};
  integrationsConfig = import ./integrations.nix {inherit config lib cfg;};
in {
  config = lib.mkIf cfg.enable {
    hjem.users.${config.user.name} = {
      packages = [
        pkgs.hyprwayland-scanner
        pkgs.hyprland # Use nixpkgs version for npins compatibility
        pkgs.grim
        pkgs.slurp
        pkgs.wl-clipboard
        pkgs.jq
        pkgs.swaybg
      ];
      files = {
        ".config/hypr/hyprland.conf" = {
          clobber = true;
          text = let
            hyprlandConfig = let
              baseConfig = lib.foldl lib.recursiveUpdate {} [
                coreConfig
                integrationsConfig
              ];
              allBinds = (keybindingsConfig.bind or []) ++ (integrationsConfig.bind or []);
              allBindm = (keybindingsConfig.bindm or []) ++ (integrationsConfig.bindm or []);
              allBindr = (keybindingsConfig.bindr or []) ++ (integrationsConfig.bindr or []);
              allBinds_hold = (keybindingsConfig.binds or []) ++ (integrationsConfig.binds or []);
            in
              baseConfig
              // keybindingsConfig
              // integrationsConfig
              // {
                bind = allBinds;
                bindm = allBindm;
                bindr = allBindr;
                binds = allBinds_hold;
              };
            pluginsConfig = lib.optionalString cfg.hy3.enable (
              generators.pluginsToHyprconf [
                (
                  if cfg.flake.enable
                  then inputs.hy3.packages.${pkgs.system}.hy3
                  else pkgs.hyprlandPlugins.hy3
                )
              ] ["$"]
            );
            mainConfig = generators.toHyprconf {
              attrs = hyprlandConfig;
              importantPrefixes = ["$" "exec" "source"];
            };
          in
            mainConfig + lib.optionalString (pluginsConfig != "") "\n${pluginsConfig}";
        };
        ".config/hypr/hyprpaper.conf" = {
          clobber = true;
          text = ''
            preload = ${config.home.directories.wallpapers.static.path}
            wallpaper = ,${config.home.directories.wallpapers.static.path}
            splash = false
            ipc = on
          '';
        };
      };
    };
  };
}
