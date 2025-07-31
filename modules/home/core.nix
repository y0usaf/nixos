{
  config,
  lib,
  pkgs,
  ...
}: let
  # Common type definitions
  t = lib.types;
  mkOpt = type: description: lib.mkOption {inherit type description;};

  # Directory module type
  dirModule = lib.types.submodule {
    options = {
      path = lib.mkOption {
        type = lib.types.str;
        description = "Absolute path to the directory";
      };
      create = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to create the directory if it doesn't exist";
      };
    };
  };

  # Configuration shortcuts
  appearanceCfg = config.home.core.appearance;
  packagesCfg = config.home.core.packages;
  userCfg = config.home.core.user;
  fontsCfg = config.home.core.fonts;
  xdgCfg = config.home.session.xdg;

  # nvide script from packages.nix
  nvide-script = pkgs.writeShellScriptBin "nvide" ''
            HELP_TEXT="Usage: nvide [OPTIONS] [working_dir]
            Arguments:
              working_dir    Directory to open (default: current directory)
            Options:
              -h, --help     Show this help message
              -n, --name     Session name (default: basename of working directory)
            Description:
              Creates an IDE-like environment with:
              - Neotree file explorer on the left
              - NeoVim in the center
              - Two terminal panes split vertically on the right
            "
            show_help() {
              echo "$HELP_TEXT"
            }
            session_name=""
            working_dir=""
            while [[ $# -gt 0 ]]; do
              case "$1" in
                -h|--help)
                  show_help
                  exit 0
                  ;;
                -n|--name)
                  if [[ -n "$2" && "$2" != -* ]]; then
                    session_name="$2"
                    shift 2
                  else
                    echo "Error: --name requires a value"
                    exit 1
                  fi
                  ;;
                -*)
                  echo "Unknown option: $1"
                  echo "Use --help for usage information."
                  exit 1
                  ;;
                *)
                  working_dir="$1"
                  shift
                  ;;
              esac
            done
            working_dir=''${working_dir:-$(pwd)}
            working_dir=$(cd "$working_dir" && pwd)
            session_name=''${session_name:-$(basename "$working_dir")}
            layout_file="/tmp/nvide-layout-$session_name.kdl"
            cat > "$layout_file" << 'INNER_EOF'
        layout {
            pane size=1 borderless=true {
                plugin location="zellij:tab-bar"
            }
            pane {
                pane split_direction="horizontal" {
                    pane size="70%" {
                        command "nvim"
                        args "."
                    }
                    pane split_direction="vertical" size="30%" {
                        pane
                        pane
                    }
                }
            }
            pane size=2 borderless=true {
                plugin location="zellij:status-bar"
            }
        }
    INNER_EOF
            if zellij list-sessions 2>/dev/null | grep -q "^$session_name$"; then
              echo "Session '$session_name' already exists. Attaching..."
              zellij attach "$session_name"
              exit 0
            fi
            echo "Creating nvide session: $session_name"
            echo "Working directory: $working_dir"
            cd "$working_dir"
            zellij --session "$session_name" --layout "$layout_file"
  '';

  # Base packages from packages.nix
  basePackages = with pkgs; [
    git
    curl
    wget
    cachix
    unzip
    bash
    lsd
    alejandra
    tree
    bottom
    psmisc
    kitty
    dconf
    lm_sensors
    networkmanager
    nvide-script
  ];
in {
  options = {
    # From appearance.nix
    home.core.appearance = {
      enable = lib.mkEnableOption "appearance settings";
      fonts = lib.mkOption {
        type = t.submodule {
          options = {
            main = lib.mkOption {
              type = t.listOf (t.submodule {
                options = {
                  package = lib.mkOption {
                    type = t.package;
                    description = "Font package";
                  };
                  name = lib.mkOption {
                    type = t.str;
                    description = "Font name";
                  };
                };
              });
              description = "List of font configurations for main fonts";
            };
            fallback = lib.mkOption {
              type = t.listOf (t.submodule {
                options = {
                  package = lib.mkOption {
                    type = t.package;
                    description = "Font package";
                  };
                  name = lib.mkOption {
                    type = t.str;
                    description = "Font name";
                  };
                };
              });
              default = [];
              description = "List of font configurations for fallback fonts";
            };
          };
        };
        description = "System font configuration";
      };
      baseFontSize = lib.mkOption {
        type = t.int;
        default = 12;
        description = "Base font size that other UI elements should scale from";
      };
      cursorSize = lib.mkOption {
        type = t.int;
        default = 24;
        description = "Size of the system cursor";
      };
      dpi = lib.mkOption {
        type = t.int;
        default = 96;
        description = "Display DPI setting for the system";
      };
      animations = lib.mkOption {
        type = t.submodule {
          options = {
            enable = lib.mkOption {
              type = t.bool;
              default = true;
              description = "Whether to enable animations globally across all applications";
            };
          };
        };
        default = {};
        description = "Global animation configuration for the system";
      };
    };

    # From defaults.nix
    home.core.defaults = {
      browser = lib.mkOption {
        type = lib.types.str;
        default = "firefox";
        description = "Default web browser";
      };
      editor = lib.mkOption {
        type = lib.types.str;
        default = "nvim";
        description = "Default text editor";
      };
      ide = lib.mkOption {
        type = lib.types.str;
        default = "cursor";
        description = "Default IDE";
      };
      terminal = lib.mkOption {
        type = lib.types.str;
        default = "foot";
        description = "Default terminal emulator";
      };
      fileManager = lib.mkOption {
        type = lib.types.str;
        default = "pcmanfm";
        description = "Default file manager";
      };
      launcher = lib.mkOption {
        type = lib.types.str;
        default = "foot -a 'launcher' ${config.user.configDirectory}/scripts/sway-launcher-desktop.sh";
        description = "Default application launcher";
      };
      discord = lib.mkOption {
        type = lib.types.str;
        default = "discord-canary";
        description = "Default Discord client";
      };
      archiveManager = lib.mkOption {
        type = lib.types.str;
        default = "7z";
        description = "Default archive manager";
      };
      imageViewer = lib.mkOption {
        type = lib.types.str;
        default = "imv";
        description = "Default image viewer";
      };
      mediaPlayer = lib.mkOption {
        type = lib.types.str;
        default = "mpv";
        description = "Default media player";
      };
    };

    # From directories.nix
    home.directories = {
      flake = mkOpt dirModule "The directory where the flake lives.";
      music = mkOpt dirModule "Directory for music files.";
      dcim = mkOpt dirModule "Directory for pictures (DCIM).";
      steam = mkOpt dirModule "Directory for Steam.";
      wallpapers = mkOpt (t.submodule {
        options = {
          static = mkOpt dirModule "Wallpaper directory for static images.";
          video = mkOpt dirModule "Wallpaper directory for videos.";
        };
      }) "Wallpaper directories configuration";
    };

    # From fonts-presets.nix
    home.core.fonts = {
      preset = lib.mkOption {
        type = t.enum ["fast-mono" "system" "noto" "custom"];
        default = "fast-mono";
        description = "Font preset to use";
      };

      customFonts = lib.mkOption {
        type = t.submodule {
          options = {
            main = lib.mkOption {
              type = t.listOf (t.submodule {
                options = {
                  package = lib.mkOption {
                    type = t.package;
                    description = "Font package";
                  };
                  name = lib.mkOption {
                    type = t.str;
                    description = "Font name";
                  };
                };
              });
              default = [];
              description = "Main font configurations";
            };
            fallback = lib.mkOption {
              type = t.listOf (t.submodule {
                options = {
                  package = lib.mkOption {
                    type = t.package;
                    description = "Font package";
                  };
                  name = lib.mkOption {
                    type = t.str;
                    description = "Font name";
                  };
                };
              });
              default = [];
              description = "Fallback font configurations";
            };
          };
        };
        default = {
          main = [];
          fallback = [];
        };
        description = "Custom font configurations when preset is 'custom'";
      };
    };

    # From packages.nix
    home.core.packages = {
      enable = lib.mkEnableOption "core packages and base system tools";
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional packages to install";
      };
    };

    # From user.nix
    home.core.user = {
      enable = lib.mkEnableOption "user configuration (packages and bookmarks)";
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "List of additional user-specific packages";
      };
      bookmarks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "GTK bookmarks for file manager";
      };
    };

    # From xdg.nix
    home.session.xdg = {
      enable = lib.mkEnableOption "XDG directory configuration";
    };
  };

  config = lib.mkMerge [
    # From appearance.nix - empty config section
    (lib.mkIf appearanceCfg.enable {
      })

    # From defaults.nix - empty config section
    {
    }

    # From fonts-presets.nix - font preset configuration
    {
      home.core.appearance.fonts =
        if fontsCfg.preset == "fast-mono"
        then {
          main = [
            {
              package = pkgs.fastFonts;
              name = "Fast_Mono";
            }
          ];
          fallback = [
            {
              package = pkgs.noto-fonts-emoji;
              name = "Noto Color Emoji";
            }
            {
              package = pkgs.noto-fonts-cjk-sans;
              name = "Noto Sans CJK";
            }
            {
              package = pkgs.font-awesome;
              name = "Font Awesome";
            }
          ];
        }
        else if fontsCfg.preset == "system"
        then {
          main = [
            {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Sans Mono";
            }
          ];
          fallback = [
            {
              package = pkgs.noto-fonts-emoji;
              name = "Noto Color Emoji";
            }
            {
              package = pkgs.liberation_ttf;
              name = "Liberation Sans";
            }
          ];
        }
        else if fontsCfg.preset == "noto"
        then {
          main = [
            {
              package = pkgs.noto-fonts-monospace-cjk;
              name = "Noto Sans Mono CJK";
            }
          ];
          fallback = [
            {
              package = pkgs.noto-fonts-emoji;
              name = "Noto Color Emoji";
            }
            {
              package = pkgs.noto-fonts;
              name = "Noto Sans";
            }
            {
              package = pkgs.noto-fonts-cjk-sans;
              name = "Noto Sans CJK";
            }
          ];
        }
        else {
          inherit (fontsCfg.customFonts) main;
          inherit (fontsCfg.customFonts) fallback;
        };
    }

    # From packages.nix - package installation
    (lib.mkIf packagesCfg.enable {
      hjem.users.${config.user.name}.packages = basePackages ++ packagesCfg.extraPackages;
    })

    # From user.nix - empty config section
    (lib.mkIf userCfg.enable {
      })

    # From xdg.nix - XDG configuration files
    (lib.mkIf xdgCfg.enable {
      hjem.users.${config.user.name}.files = {
        ".zshenv" = {
          clobber = true;
          text = lib.mkAfter ''
            export XDG_CONFIG_HOME="$HOME/.config"
            export XDG_DATA_HOME="$HOME/.local/share"
            export XDG_STATE_HOME="$HOME/.local/state"
            export XDG_CACHE_HOME="$HOME/.cache"
            export XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
            export XDG_WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
            export ANDROID_HOME="$XDG_DATA_HOME/android"
            export ADB_VENDOR_KEY="$XDG_CONFIG_HOME/android"
            export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
            export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
            export NPM_CONFIG_PREFIX="$XDG_DATA_HOME/npm"
            export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
            export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME/npm/config/npm-init.js"
            export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"
            export KERAS_HOME="$XDG_STATE_HOME/keras"
            export NIMBLE_DIR="$XDG_DATA_HOME/nimble"
            export DOTNET_CLI_HOME="$XDG_DATA_HOME/dotnet"
            export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
            export CARGO_HOME="$XDG_DATA_HOME/cargo"
            export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
            export GOPATH="$XDG_DATA_HOME/go"
            export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=\"$XDG_CONFIG_HOME/java\""
            export LESSHISTFILE="$XDG_STATE_HOME/less/history"
            export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"
            export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
            export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite_history"
            export WGET_HSTS_FILE="$XDG_DATA_HOME/wget-hsts"
            export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
            export HISTFILE="$XDG_STATE_HOME/zsh/history"
            export GNUPGHOME="$XDG_DATA_HOME/gnupg"
            export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
            export SPOTDL_CONFIG="$XDG_CONFIG_HOME/spotdl.yml"
            export DVDCSS_CACHE="$XDG_DATA_HOME/dvdcss"
            export WINEPREFIX="$XDG_DATA_HOME/wine"
            export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
            export SSB_HOME="$XDG_DATA_HOME/zoom"
            export __GL_SHADER_DISK_CACHE_PATH="$XDG_CACHE_HOME/nv"
          '';
        };
        ".config/user-dirs.dirs" = {
          clobber = true;
          text = ''
            XDG_DESKTOP_DIR="${config.user.homeDirectory}/Desktop"
            XDG_DOWNLOAD_DIR="${config.user.homeDirectory}/Downloads"
            XDG_TEMPLATES_DIR="${config.user.homeDirectory}/Templates"
            XDG_PUBLICSHARE_DIR="${config.user.homeDirectory}/Public"
            XDG_DOCUMENTS_DIR="${config.user.homeDirectory}/Documents"
            XDG_MUSIC_DIR="${config.user.homeDirectory}/Music"
            XDG_PICTURES_DIR="${config.user.homeDirectory}/Pictures"
            XDG_VIDEOS_DIR="${config.user.homeDirectory}/Videos"
            XDG_SCREENSHOTS_DIR="${config.user.homeDirectory}/Pictures/Screenshots"
            XDG_WALLPAPERS_DIR="${config.user.homeDirectory}/Pictures/Wallpapers"
          '';
        };
        ".config/mimeapps.list" = {
          clobber = true;
          text = ''
            [Default Applications]
            text/html=firefox.desktop
            x-scheme-handler/http=firefox.desktop
            x-scheme-handler/https=firefox.desktop
            x-scheme-handler/ftp=firefox.desktop
            x-scheme-handler/chrome=firefox.desktop
            x-scheme-handler/discord=discord.desktop
            inode/directory=pcmanfm.desktop
            video/mp4=mpv.desktop
            video/x-matroska=mpv.desktop
            video/webm=mpv.desktop
            image/jpeg=imv.desktop
            image/png=imv.desktop
            image/gif=imv.desktop
            image/tiff=imv.desktop
            image/bmp=imv.desktop
            application/zip=file-roller.desktop
            application/x-7z-compressed=file-roller.desktop
            application/x-tar=file-roller.desktop
            application/gzip=file-roller.desktop
            application/x-compressed-tar=file-roller.desktop
            application/x-extension-htm=firefox.desktop
            application/x-extension-html=firefox.desktop
            application/x-extension-shtml=firefox.desktop
            application/xhtml+xml=firefox.desktop
            application/x-extension-xhtml=firefox.desktop
            [Added Associations]
            text/html=firefox.desktop
            x-scheme-handler/http=firefox.desktop
            x-scheme-handler/https=firefox.desktop
            x-scheme-handler/ftp=firefox.desktop
          '';
        };
        ".local/share/applications/firefox.desktop" = {
          clobber = true;
          text = ''
            [Desktop Entry]
            Name=Firefox
            GenericName=Web Browser
            Exec=firefox %U
            Terminal=false
            Type=Application
            Categories=Application;Network;WebBrowser;
            MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
            Icon=firefox
            StartupNotify=true
          '';
        };
        ".config/python/pythonrc" = {
          clobber = true;
          text = ''
            import os
            import atexit
            import readline
            histfile = os.path.join(os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")), "python_history")
            try:
                readline.read_history_file(histfile)
                h_len = readline.get_current_history_length()
            except FileNotFoundError:
                open(histfile, 'wb').close()
                h_len = 0
            def save(prev_h_len, histfile):
                new_h_len = readline.get_current_history_length()
                readline.set_history_length(1000)
                readline.append_history_file(new_h_len - prev_h_len, histfile)
            atexit.register(save, h_len, histfile)
          '';
        };
      };
    })
  ];
}
