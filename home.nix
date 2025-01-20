#─────────────────────── 🏠 HOME MANAGER CONFIG ────────────────────────#
# 🏠 User-specific settings | Home-manager rebuild needed for changes  #
#──────────────────────────────────────────────────────────────────────#
{
  config,
  pkgs,
  lib,
  inputs,
  globals,
  ...
}: {
  #── 🏠 Core Settings ──────────────────────#
  home = {
    username = globals.username;
    homeDirectory = globals.homeDirectory;
    stateVersion = globals.stateVersion;
    enableNixpkgsReleaseCheck = false;
  };

  #── 📦 User Packages ───────────────────────#
  home.packages = with pkgs; [
    #── 🎨 Development Tools ─────────────────#
    neovim
    cmake
    meson
    bottom
    code-cursor
    alejandra
    cpio
    pkg-config
    ninja
    gcc

    #── 🌐 Web Applications ─────────────────#
    firefox
    vesktop
    discord-canary

    #── 🔧 Terminal and System Utilities ────#
    foot
    pavucontrol
    nitch
    microfetch
    sway-launcher-desktop
    pcmanfm
    syncthing
    lsd
    vial
    waybar
    p7zip

    #── 🎮 Gaming ────────────────────────────#
    steam
    protonup-qt
    gamemode
    protontricks
    prismlauncher

    #── 📺 Media and Streaming ──────────────#
    imv
    mpv
    vlc
    stremio
    ffmpeg
    cmus

    #── 🖥️ Wayland Utilities ───────────────#
    grim
    slurp
    wl-clipboard
    nwg-wrapper
  ];

  #── 🔧 Program Configurations ────────────#
  imports = [
    ./hyprland.nix
    ./zsh.nix
    ./ssh.nix
    ./git.nix
    ./xdg.nix
    ./fonts.nix
    ./foot.nix
    ./gtk.nix
    ./cursor.nix
    ./ags.nix
  ];

  #── 🎥 OBS Studio ────────────────────────#
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
      obs-vkcapture
      inputs.obs-image-reaction.packages.${pkgs.system}.default
    ];
  };

  #── 📦 Package Manager ──────────────────#
  programs.nh = {
    enable = true;
    package = pkgs.nh;
  };

  #── 🔄 Systemd Services ─────────────────#

  #── ✨ Nix Format Service ───────────────#
  systemd.user.services.format-nix = {
    Unit = {
      Description = "Format Nix files on change";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.alejandra}/bin/alejandra .";
      WorkingDirectory = "/home/y0usaf/nixos";
    };
  };

  systemd.user.paths.format-nix = {
    Unit = {
      Description = "Watch NixOS config directory for changes";
    };
    Path = {
      PathModified = "/home/y0usaf/nixos";
      Unit = "format-nix.service";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  #── 🔐 Polkit Authentication ────────────#
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      WantedBy = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  #── 🚌 DBus Environment ─────────────────#
  systemd.user.services.dbus-hyprland-environment = {
    Unit = {
      Description = "dbus hyprland environment";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP";
      RemainAfterExit = true;
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  systemd.user.startServices = "sd-switch";
}
