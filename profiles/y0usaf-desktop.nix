#───────────────────────── 🖥️ DESKTOP PROFILE 🖥️ ─────────────────────────#
# Personal configuration for y0usaf-desktop                                #
#──────────────────────────────────────────────────────────────────────────#
let
  username = "y0usaf";
in {
  username = username;
  homeDirectory = "/home/${username}";
  hostname = "y0usaf-desktop";
  stateVersion = "24.11";
  timezone = "America/Toronto";

  features = [
    "hyprland"
    "wayland"
    "ags"
    "nvidia"
    "gaming"
    "development"
    "media"
    "creative"
    "virtualization"
    "backup"
    "neovim"
    "android"
    "webapps"
    "wallust"
  ];

  flakeDir = "/home/${username}/nixos";
  musicDir = "$HOME/Music";
  dcimDir = "$HOME/DCIM";
  steamDir = "$HOME/.local/share/Steam";
  wallpaperDir = "$HOME/DCIM/Wallpapers/32_9";
  wallpaperVideoDir = "$HOME/DCIM/Wallpapers_Video";

  defaultBrowser = {
    package = "firefox";
    command = "firefox";
  };
  defaultEditor = {
    package = "neovim";
    command = "nvim";
  };
  defaultIde = {
    package = "code-cursor";
    command = "cursor";
  };
  defaultTerminal = {
    package = "foot";
    command = "foot";
  };
  defaultFileManager = {
    package = "pcmanfm";
    command = "pcmanfm";
  };
  defaultLauncher = {
    package = "sway-launcher-desktop";
    command = "foot -a launcher sway-launcher-desktop";
  };
  defaultDiscord = {
    package = "discord";
    command = "discord";
  };
  defaultArchiveManager = {
    package = "p7zip";
    command = "7z";
  };
  defaultImageViewer = {
    package = "imv";
    command = "imv";
  };
  defaultMediaPlayer = {
    package = "mpv";
    command = "mpv";
  };

  gitName = "y0usaf";
  gitEmail = "OA99@Outlook.com";
  gitHomeManagerRepoUrl = "git@github.com:y0usaf/nixos.git";

  dpi = 109;
  baseFontSize = 12;
  cursorSize = 24;

  mainFont = {
    packages = ["terminus_font_ttf"];
    names = ["Terminus (TTF)"];
  };

  fallbackFonts = {
    packages = ["noto-fonts-emoji" "noto-fonts-cjk-sans" "font-awesome"];
    names = ["Noto Color Emoji" "Noto Sans CJK" "Font Awesome"];
  };

  directories = {
    flake.path = "/home/${username}/nixos";
    music.path = "$HOME/Music";
    dcim.path = "$HOME/DCIM";
    steam = {
      path = "$HOME/.local/share/Steam";
      create = false; # Don't create Steam dir automatically
    };
  };
}
