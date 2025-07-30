{
  config,
  pkgs,
  lib,
  ...
}: let
  wallustCfg = config.home.ui.wallust;
  quickshellCfg = config.home.ui.quickshell;
  waylandCfg = config.home.ui.wayland;
  username = config.user.name;
in {
  options.home.ui = {
    wallust.enable = lib.mkEnableOption "wallust color generation";

    quickshell.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Quickshell desktop shell";
    };

    wayland.enable = lib.mkEnableOption "Wayland configuration";
  };

  config = lib.mkMerge [
    # Wallust configuration
    (lib.mkIf wallustCfg.enable {
      hjem.users.${username}.packages = with pkgs; [
        wallust
      ];
    })

    # Quickshell configuration
    (lib.mkIf quickshellCfg.enable {
      hjem.users.${username}.packages = with pkgs; [
        quickshell
        cava
      ];
    })

    # Wayland configuration
    (lib.mkIf waylandCfg.enable {
      hjem.users.${username} = {
        packages = with pkgs; [
          grim
          slurp
          wl-clipboard
          hyprpicker
        ];
        files = {
          ".config/zsh/.zshenv" = {
            text = lib.mkAfter ''
              export WLR_NO_HARDWARE_CURSORS=1
              export NIXOS_OZONE_WL=1
              export QT_QPA_PLATFORM=wayland
              export ELECTRON_OZONE_PLATFORM_HINT=wayland
              export XDG_SESSION_TYPE=wayland
              export GDK_BACKEND=wayland,x11
              export SDL_VIDEODRIVER=wayland
              export CLUTTER_BACKEND=wayland
            '';
            clobber = true;
          };
        };
      };
    })
  ];
}
