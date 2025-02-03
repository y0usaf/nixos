#─────────────────────── 🌍 ENVIRONMENT CONFIG ────────────────────────#
# ⚙️ System and User Environment Variables Configuration              #
#──────────────────────────────────────────────────────────────────────#
{
  config,
  pkgs,
  lib,
  profile,
  ...
}: {
  #── ⚙️ System-wide Environment Setup ─────────────────────────────────#
  environment.sessionVariables = lib.mkMerge [
    {
      # Non-Wayland variables here
    }
    (lib.mkIf (builtins.elem "wayland" profile.features) {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland,x11";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
    })
    (lib.mkIf (builtins.elem "hyprland" profile.features) {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
    })
  ];

  #── 🏠 User Environment Configuration ─────────────────────────────────#
  home-manager.users.${profile.username} = {
    home = {
      #── ⚡ User Session Environment ─────────────────────────────────#
      sessionVariables = {
        #── 🌐 Browser & Display Protocol Settings ──────────────────#
        MOZ_ENABLE_WAYLAND = "1";
        LIBSEAT_BACKEND = "logind";

        #── 📦 Package Management Settings ──────────────────────────#
        NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
      };

      #── ⚡ Binary & Executable Paths ─────────────────────────────#
      sessionPath = [
        "$(npm root -g)/.bin"
        "$HOME/.local/bin"
        "/usr/lib/google-cloud-sdk/bin"
      ];
    };

    #── ⚡ Hyprland Compositor Settings ───────────────────────────────#
    wayland.windowManager.hyprland.settings = {
      env = lib.mkIf (builtins.elem "nvidia" profile.features) [
        "LIBVA_DRIVER_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];
    };

    #── 🔐 Secure Token Management ──────────────────────────────────#
    home.sessionVariables.envExtra = ''
      # 🔑 Auto-load tokens from files
      if [ -d "$HOME/Tokens" ]; then
        for f in "$HOME/Tokens"/*.txt; do
          [ -f "$f" ] && export "$(basename "$f" .txt)"="$(cat "$f")"
        done
      fi
    '';
  };
}
