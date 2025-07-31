{
  config,
  pkgs,
  lib,
  hostSystem,
  ...
}: let
  obsConfig = config.home.programs.obs;
  firefoxConfig = config.home.programs.firefox;
  androidConfig = config.home.programs.android;
  username = config.user.name;

  nvidiaCudaEnabled = hostSystem.hardware.nvidia.enable && (hostSystem.hardware.nvidia.cuda.enable or false);
  obsPackage =
    if nvidiaCudaEnabled
    then pkgs.obs-studio.override {cudaSupport = true;}
    else pkgs.obs-studio;

  # Firefox configuration data
  firefoxCommonSettings = {
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "gfx.webrender.all" =
      if config.system.hardware.nvidia.enable or false
      then false
      else true;
    "media.hardware-video-decoding.enabled" =
      if config.system.hardware.nvidia.enable or false
      then false
      else true;
    "media.ffmpeg.vaapi.enabled" =
      if config.system.hardware.nvidia.enable or false
      then false
      else true;
    "layers.acceleration.disabled" =
      if config.system.hardware.nvidia.enable or false
      then true
      else false;
    "browser.sessionstore.interval" = 15000;
    "network.http.max-persistent-connections-per-server" = 10;
    "browser.cache.disk.enable" = false;
    "browser.cache.memory.enable" = true;
    "browser.cache.memory.capacity" = 1048576;
    "browser.sessionhistory.max_entries" = 50;
    "network.prefetch-next" = true;
    "network.dns.disablePrefetch" = false;
    "network.predictor.enabled" = true;
    "browser.tabs.drawInTitlebar" = true;
    "browser.theme.toolbar-theme" = 0;
    "devtools.chrome.enabled" = true;
    "devtools.debugger.remote-enabled" = true;
    "devtools.debugger.prompt-connection" = false;
    "browser.enabledE10S" = false;
    "browser.theme.dark-private-windows" = false;
    "dom.webcomponents.enabled" = true;
    "layout.css.shadow-parts.enabled" = true;
  };

  firefoxUserJs = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      key: value: let
        jsValue =
          if builtins.isBool value
          then
            (
              if value
              then "true"
              else "false"
            )
          else if builtins.isInt value
          then toString value
          else if builtins.isString value
          then ''"${value}"''
          else toString value;
      in ''user_pref("${key}", ${jsValue});''
    )
    firefoxCommonSettings
  );

  firefoxPolicies = builtins.toJSON {
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = false;
      };
      ExtensionSettings = {
        "*" = {
          installation_mode = "allowed";
          allowed_types = ["extension" "theme"];
        };
      };
    };
  };

  firefoxUserChrome = ''
    /* Disable all animations */
    * {
      animation: none;
      transition: none;
      scroll-behavior: auto;
      padding: 0;
      margin: 0;
    }
    :root {
        /* Base sizing variables */
        --tab-font-size: 0.8em;
        --max-tab-width: none;
        --show-titlebar-buttons: none;
        --tab-height: 12pt;
        --toolbar-icon-size: calc(var(--tab-height) / 1.5);
        /* Spacing variables */
        --uc-spacing-small: 1pt;
        --uc-spacing-medium: 2pt;
        --uc-spacing-large: 4pt;
        /* Layout variables */
        --uc-bottom-toolbar-height: 12pt;
        --uc-navbar-width: 75vw;
        --uc-urlbar-width: 50vw;
        --uc-urlbar-bottom-offset: calc(var(--uc-bottom-toolbar-height) + var(--uc-spacing-medium));
        /* Animation control */
        --uc-animation-duration: 0.001s;
        --uc-transition-duration: 0.001s;
    }
    /* Disable specific Firefox animations */
    @media (prefers-reduced-motion: no-preference) {
      * {
        animation-duration: var(--uc-animation-duration);
        transition-duration: var(--uc-transition-duration);
      }
    }
    /* Disable smooth scrolling */
    html {
      scroll-behavior: auto;
    }
    /* Disable tab animations */
    .tabbrowser-tab {
      transition: none;
    }
    /* Disable toolbar animations */
    :root[tabsintitlebar]
        transition: none;
    }
    /* Rest of your existing CSS */
    .titlebar-buttonbox-container {
        display: var(--show-titlebar-buttons)
    }
    :root:not([customizing])
        margin-left: var(--uc-spacing-small);
        margin-right: var(--uc-spacing-small);
        border-radius: 0;
        padding: 0;
        min-height: 0;
    }
    .tabbrowser-tab * {
        margin: 0;
        border-radius: 0;
    }
    .tabbrowser-tab {
        height: var(--tab-height);
        font-size: var(--tab-font-size);
        min-height: 0;
        align-items: center;
        margin-bottom: var(--uc-spacing-medium);
    }
    .tab-icon-image {
        height: auto;
        width: var(--toolbar-icon-size);
        margin-right: var(--uc-spacing-medium);
    }
        min-height: 0;
    }
    :root:not([customizing])
    :root:not([customizing])
    :root:not([customizing])
    :root:not([customizing])
        -moz-appearance: none;
        padding-top: 0;
        padding-bottom: 0;
        -moz-box-align: stretch;
        margin: 0;
    }
        background-color: var(--toolbarbutton-hover-background);
    }
        padding: 0;
        transform: scale(0.6);
        background-color: transparent;
    }
    @media (-moz-os-version: windows-win10) {
        :root[sizemode=maximized]
            padding-top: calc(var(--uc-spacing-large) + var(--uc-spacing-medium));
        }
    }
        position: fixed;
        bottom: 0;
        width: var(--uc-navbar-width);
        height: var(--uc-bottom-toolbar-height);
        max-height: var(--uc-bottom-toolbar-height);
        margin: calc(-1 * var(--uc-spacing-small)) auto 0;
        border-top: none;
        left: 0;
        right: 0;
        z-index: 3;
    }
        margin-bottom: var(--uc-bottom-toolbar-height);
    }
        --uc-flex-justify: center
    }
    scrollbox[orient=horizontal]>slot {
        justify-content: var(--uc-flex-justify, initial)
    }
        height: var(--tab-height);
    }
        min-height: var(--tab-height);
    }
        min-height: 0;
    }
        height: auto;
    }
    .searchbar-search-icon,
    .urlbar-page-action {
        height: auto;
        width: var(--toolbar-icon-size);
        padding: 0;
    }
    .toolbarbutton-1 {
        padding: 0 var(--uc-spacing-medium);
    }
    .toolbarbutton-1,
    .toolbarbutton-icon {
        -moz-appearance: none;
        padding-inline: var(--uc-spacing-small);
        -moz-box-align: stretch;
        margin: 0;
    }
    .titlebar-button,
    .toolbaritem-combined-buttons {
        -moz-appearance: none;
        padding-top: 0;
        padding-bottom: 0;
        padding-inline: var(--uc-spacing-small);
        -moz-box-align: stretch;
        margin: 0;
    }
    .tab-close-button,
    .urlbar-icon,
    .urlbar-page-action {
        -moz-appearance: none;
        padding-inline: var(--uc-spacing-small);
        -moz-box-align: stretch;
        margin: 0;
    }
    .urlbar-page-action {
        padding-top: 0;
        padding-bottom: 0;
    }
    .tab-close-button,
    .titlebar-button > image,
    .toolbarbutton-icon,
    .urlbar-icon,
    .urlbar-page-action > image {
        padding: 0;
        width: var(--toolbar-icon-size);
        height: auto;
    }
        -moz-appearance: none;
        background: none;
        border: none;
        box-shadow: none;
    }
    :root[tabsintitlebar]
        padding-right: 0;
        padding-left: 0;
    }
    :root[tabsintitlebar]
        padding-right: 0;
        padding-left: 0;
    }
        display: none;
    }
        height: calc(100vh - var(--uc-bottom-toolbar-height));
    }
        max-height: calc(100vh - var(--uc-bottom-toolbar-height));
    }
    @media screen and (max-width: 1000px) {
            width: 100vw;
        }
        :root {
            --uc-navbar-width: 100vw;
        }
    }
    .tab-content {
        padding-inline-start: var(--uc-spacing-small);
        padding-inline-end: var(--uc-spacing-small);
    }
    .tab-label {
        margin-inline-end: 0;
    }
    .tab-icon-sound {
        margin-inline-start: var(--uc-spacing-small);
    }
    :root[customizing]
        position: initial;
        width: initial;
        background: var(--toolbar-bgcolor);
    }
    :root[customizing]
        margin-bottom: 0;
    }
        --toolbarbutton-border-radius: 0;
        --urlbar-icon-border-radius: 0;
        backdrop-filter: blur(10px);
        background-color: transparent \!important;
    }
        --toolbarbutton-border-radius: 0;
        --urlbar-icon-border-radius: 0;
    }
  '';
in {
  options = {
    # programs/obs.nix (28 lines -> INLINED\!)
    home.programs.obs = {
      enable = lib.mkEnableOption "OBS Studio";
    };
    # programs/firefox/* (5 files -> CONSOLIDATED\!)
    home.programs.firefox = {
      enable = lib.mkEnableOption "Firefox browser with optimized settings";
    };
    # programs/android.nix (50 lines -> INLINED\!)
    home.programs.android = {
      enable = lib.mkEnableOption "android tools and waydroid";
    };
    # Missing options that were removed during consolidation - adding back for compatibility
    home.programs.discord = {
      enable = lib.mkEnableOption "Discord communication";
    };
    home.programs.obsidian = {
      enable = lib.mkEnableOption "Obsidian note-taking app";
    };
    # vesktop already inlined in default.nix
    home.programs.webapps = {
      enable = lib.mkEnableOption "Web applications";
    };
    home.programs.sway-launcher-desktop = {
      enable = lib.mkEnableOption "Sway launcher desktop";
    };
    # imv already inlined in default.nix
    # mpv already inlined in default.nix
    # pcmanfm already inlined in default.nix
    # qbittorrent already inlined in default.nix
    # stremio already inlined in default.nix
    home.programs.bambu = {
      enable = lib.mkEnableOption "Bambu tools";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf obsConfig.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [
        obsPackage
        obs-studio-plugins.obs-backgroundremoval
        obs-studio-plugins.obs-vkcapture
        obs-studio-plugins.obs-pipewire-audio-capture
        # inputs.obs-image-reaction.packages.${pkgs.system}.default # TODO: Fix for npins
        v4l-utils
      ];
    })
    (lib.mkIf firefoxConfig.enable {
      hjem.users.${username} = {
        packages = with pkgs; [
          firefox
        ];
        files = {
          ".profile" = {
            text = lib.mkAfter ''
              export MOZ_ENABLE_WAYLAND=1
              export MOZ_USE_XINPUT2=1
            '';
            clobber = true;
          };
          ".mozilla/firefox/${username}.default/user.js" = {
            text = firefoxUserJs;
            clobber = true;
          };
          ".mozilla/firefox/${username}.default-release/user.js" = {
            text = firefoxUserJs;
            clobber = true;
          };
          ".mozilla/firefox/policies/policies.json" = {
            text = firefoxPolicies;
            clobber = true;
          };
          ".mozilla/firefox/${username}.default/chrome/userChrome.css" = {
            text = firefoxUserChrome;
            clobber = true;
          };
          ".mozilla/firefox/${username}.default-release/chrome/userChrome.css" = {
            text = firefoxUserChrome;
            clobber = true;
          };
        };
      };
    })
    (lib.mkIf androidConfig.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          waydroid
          android-tools
          scrcpy
        ];
        files = {
          ".android_env" = {
            clobber = true;
            text = ''
              export ANDROID_HOME="$XDG_DATA_HOME/android"
              export ADB_VENDOR_KEY="$XDG_CONFIG_HOME/android"
            '';
          };
        };
      };
      systemd.user.services = {
        waydroid-container = {
          Unit = {
            Description = "Waydroid Container";
            After = ["graphical-session.target"];
            PartOf = ["graphical-session.target"];
            Requires = ["waydroid-container.service"];
          };
          Service = {
            Type = "simple";
            Environment = [
              "WAYDROID_EXTRA_ARGS=--gpu-mode host"
              "LIBGL_DRIVER_NAME=nvidia"
              "GBM_BACKEND=nvidia-drm"
              "__GLX_VENDOR_LIBRARY_NAME=nvidia"
            ];
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
            ExecStart = "${pkgs.waydroid}/bin/waydroid session start";
            ExecStop = "${pkgs.waydroid}/bin/waydroid session stop";
            Restart = "on-failure";
            RestartSec = "5s";
          };
          Install = {
            WantedBy = ["graphical-session.target"];
          };
        };
      };
    })
    # Basic implementations for missing options - add packages when enabled
    (lib.mkIf config.home.programs.discord.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [
        # Use discord-canary as specified in user defaults, with vencord integration
        (discord-canary.override {
          withOpenASAR = true;
          withVencord = true;
        })
      ];
    })
    (lib.mkIf config.home.programs.obsidian.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [obsidian];
    })
    # vesktop config already inlined in default.nix
    (lib.mkIf config.home.programs.webapps.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          ungoogled-chromium
        ];
        files = {
          ".local/share/applications/keybard.desktop" = {
            text = ''
              [Desktop Entry]
              Name=Keybard
              Exec=${lib.getExe pkgs.chromium} --app=https://captdeaf.github.io/keybard %U
              Terminal=false
              Type=Application
              Categories=Utility;System;
              Comment=Keyboard testing utility
            '';
            clobber = true;
          };
          ".local/share/applications/google-meet.desktop" = {
            text = ''
              [Desktop Entry]
              Name=Google Meet
              Exec=${lib.getExe pkgs.chromium} --app=https://meet.google.com %U
              Terminal=false
              Type=Application
              Categories=Network;VideoConference;Chat;
              Comment=Video conferencing by Google
            '';
            clobber = true;
          };
        };
      };
    })
    (lib.mkIf config.home.programs.sway-launcher-desktop.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          fzf
        ];
        files.".config/scripts/sway-launcher-desktop.sh" = {
          clobber = true;
          executable = true;
          text = ''
            #!/usr/bin/env bash
            # terminal application launcher for sway, using fzf
            # Based on: https://gitlab.com/FlyingWombat/my-scripts/blob/master/sway-launcher
            # https://gist.github.com/Biont/40ef59652acf3673520c7a03c9f22d2a
            shopt -s nullglob globstar
            set -o pipefail
            # Ensure file descriptor 3 is available for debug output
            exec 3>/dev/null 2>/dev/null || true
            # shellcheck disable=SC2154
            trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
            IFS=$'\n\t'
            DEL=$'\34'

            FZF_COMMAND="''${FZF_COMMAND:=fzf}"
            TERMINAL_COMMAND="''${TERMINAL_COMMAND:="$TERMINAL -e"}"
            GLYPH_COMMAND="''${GLYPH_COMMAND-  }"
            GLYPH_DESKTOP="''${GLYPH_DESKTOP-  }"
            CONFIG_DIR="''${XDG_CONFIG_HOME:-${config.user.homeDirectory}/.config}/sway-launcher-desktop"
            PROVIDERS_FILE="''${PROVIDERS_FILE:=providers.conf}"
            if [[ "''${PROVIDERS_FILE#/}" == "''${PROVIDERS_FILE}" ]]; then
              # $PROVIDERS_FILE is a relative path, prepend $CONFIG_DIR
              PROVIDERS_FILE="''${CONFIG_DIR}/''${PROVIDERS_FILE}"
            fi
            if [[ ! -v PREVIEW_WINDOW ]]; then
                PREVIEW_WINDOW=up:2:noborder
            fi

            # Provider config entries are separated by the field separator \034 and have the following structure:
            # list_cmd,preview_cmd,launch_cmd,purge_cmd
            declare -A PROVIDERS
            if [ -f "''${PROVIDERS_FILE}" ]; then
              eval "$(awk -F= '
              BEGINFILE{ provider=""; }
              /^\[.*\]/{sub("^\\[", "");sub("\\]$", "");provider=$0}
              /^(launch|list|preview|purge)_cmd/{st = index($0,"=");providers[provider][$1] = substr($0,st+1)}
              ENDFILE{
                for (key in providers){
                  if(!("list_cmd" in providers[key])){continue;}
                  if(!("launch_cmd" in providers[key])){continue;}
                  if(!("preview_cmd" in providers[key])){continue;}
                  if(!("purge_cmd" in providers[key])){providers[key]["purge_cmd"] = "exit 0";}
                  for (entry in providers[key]){
                   gsub(/[\x27,\047]/,"\x27\"\x27\"\x27", providers[key][entry])
                  }
                  print "PROVIDERS[\x27" key "\x27]=\x27" providers[key]["list_cmd"] "\034" providers[key]["preview_cmd"] "\034" providers[key]["launch_cmd"] "\034" providers[key]["purge_cmd"] "\x27\n"
                }
              }' "''${PROVIDERS_FILE}")"
              if [[ ! -v HIST_FILE ]]; then
                HIST_FILE="''${XDG_CACHE_HOME:-${config.user.homeDirectory}/.cache}/''${0##*/}-''${PROVIDERS_FILE##*/}-history.txt"
              fi
            else
              PROVIDERS['desktop']="''${0} list-entries''${DEL}''${0} describe-desktop \"{1}\"''${DEL}''${0} run-desktop '{1}' {2}''${DEL}test -f '{1}' || exit 43"
              PROVIDERS['command']="''${0} list-commands''${DEL}''${0} describe-command \"{1}\"''${DEL}''${TERMINAL_COMMAND} {1}''${DEL}command -v '{1}' || exit 43"
              if [[ ! -v HIST_FILE ]]; then
                HIST_FILE="''${XDG_CACHE_HOME:-${config.user.homeDirectory}/.cache}/''${0##*/}-history.txt"
              fi
            fi
            PROVIDERS['user']="exit''${DEL}exit''${DEL}{1}" # Fallback provider that simply executes the exact command if there were no matches

            if [[ -n "''${HIST_FILE}" ]]; then
              mkdir -p "''${HIST_FILE%/*}" && touch "$HIST_FILE"
              readarray HIST_LINES <"$HIST_FILE"
            fi

            function describe() {
              # shellcheck disable=SC2086
              readarray -d ''${DEL} -t PROVIDER_ARGS <<<''${PROVIDERS[''${1}]}
              # shellcheck disable=SC2086
              [ -n "''${PROVIDER_ARGS[1]}" ] && eval "''${PROVIDER_ARGS[1]//\\{1\\}/''${2}}"
            }
            function describe-desktop() {
              description=$(sed -ne '/^Comment=/{s/^Comment=//;p;q}' "$1")
              echo -e "\033[33m$(sed -ne '/^Name=/{s/^Name=//;p;q}' "$1")\033[0m"
              echo "''${description:-No description}"
            }
            function describe-command() {
              readarray arr < <(whatis -l "$1" 2>/dev/null)
              description="''${arr[0]}"
              description="''${description#* - }"
              echo -e "\033[33m''${1}\033[0m"
              echo "''${description:-No description}"
            }

            function provide() {
              # shellcheck disable=SC2086
              readarray -d ''${DEL} -t PROVIDER_ARGS <<<''${PROVIDERS[$1]}
              eval "''${PROVIDER_ARGS[0]}"
            }
            function list-commands() {
              IFS=: read -ra path <<<"$PATH"
              for dir in "''${path[@]}"; do
                printf '%s\n' "$dir/"* |
                  awk -F / -v pre="$GLYPH_COMMAND" '{print $NF "\034command\034\033[31m" pre "\033[0m" $NF;}'
              done | sort -u
            }
            function list-entries() {
              # Get locations of desktop application folders according to spec
              # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
              IFS=':' read -ra DIRS <<<"''${XDG_DATA_HOME-${config.user.homeDirectory}/.local/share}:''${XDG_DATA_DIRS-/usr/local/share:/usr/share}"
              for i in "''${!DIRS[@]}"; do
                if [[ ! -d "''${DIRS[i]}" ]]; then
                  unset -v 'DIRS[$i]'
                else
                  DIRS[$i]="''${DIRS[i]}/applications/**/*.desktop"
                fi
              done

              # shellcheck disable=SC2068
              entries ''${DIRS[@]} | sort -k2
            }
            function entries() {
              # shellcheck disable=SC2068
              awk -v pre="$GLYPH_DESKTOP" -F= '
                function desktopFileID(filename){
                  sub("^.*applications/", "", filename);
                  sub("/", "-", filename);
                  return filename
                }
                BEGINFILE{
                  application=0;
                  hidden=0;
                  block="";
                  a=0

                  id=desktopFileID(FILENAME)
                  if(id in fileIds){
                    nextfile;
                  }else{
                    fileIds[id]=0
                  }
                }
                /^\[Desktop Entry\]/{block="entry"}
                /^Type=Application/{application=1}
                /^\[Desktop Action/{
                  sub("^\\[Desktop Action ", "");
                  sub("\\]$", "");
                  block="action";
                  a++;
                  actions[a,"key"]=$0
                }
                /^\[X-/{
                  sub("^\\[X-", "");
                  sub("\\]$", "");
                  block="action";
                  a++;
                  actions[a,"key"]=$0
                }
                /^Name=/{ (block=="action")? actions[a,"name"]=$2 : name=$2 }
                /^NoDisplay=true/{ (block=="action")? actions[a,"hidden"]=1 : hidden=1 }
                ENDFILE{
                  if (application){
                      if (!hidden)
                          print FILENAME "\034desktop\034\033[33m" pre name "\033[0m";
                      if (a>0)
                          for (i=1; i<=a; i++)
                              if (!actions[i, "hidden"])
                                  print FILENAME "\034desktop\034\033[33m" pre name "\033[0m (" actions[i, "name"] ")\034" actions[i, "key"]
                  }
                }' \
                $@ </dev/null
              # the empty stdin is needed in case no *.desktop files
            }
            function run-desktop() {
              CMD="$("''${0}" generate-command "$@" 2>&3)"
              echo "Generated Launch command from .desktop file: ''${CMD}" >&3
              eval "''${CMD}"
            }
            function generate-command() {
              # Define the search pattern that specifies the block to search for within the .desktop file
              PATTERN="^\\\\[Desktop Entry\\\\]"
              if [[ -n $2 ]]; then
                PATTERN="^\\\\[Desktop Action ''${2}\\\\]"
              fi
              echo "Searching for pattern: ''${PATTERN}" >&3
              # 1. We see a line starting [Desktop, but we're already searching: deactivate search again
              # 2. We see the specified pattern: start search
              # 3. We see an Exec= line during search: remove field codes and set variable
              # 3. We see a Path= line during search: set variable
              # 4. Finally, build command line
              awk -v pattern="''${PATTERN}" -v terminal_cmd="''${TERMINAL_COMMAND}" -F= '
                BEGIN{a=0;exec=0;path=0}
                   /^\[Desktop/{
                    if(a){ a=0 }
                   }
                  $0 ~ pattern{ a=1 }
                  /^Terminal=/{
                    sub("^Terminal=", "");
                    if ($0 == "true") { terminal=1 }
                  }
                  /^Exec=/{
                    if(a && !exec){
                      sub("^Exec=", "");
                      gsub(" ?%[cDdFfikmNnUuv]", "");
                      exec=$0;
                    }
                  }
                  /^Path=/{
                    if(a && !path){ path=$2 }
                   }
                END{
                  if(path){ printf "cd " path " && " }
                  printf "exec "
                  if (terminal){ printf terminal_cmd " " }
                  print exec
                }' "$1"
            }

            function shouldAutostart() {
                local condition="$(cat $1 | grep "AutostartCondition" | cut -d'=' -f2)"
                local filename="''${XDG_CONFIG_HOME-${config.user.homeDirectory}/.config}/''${condition#* }"
                case $condition in
                    if-exists*)
                        [[ -e $filename ]]
                        ;;
                    unless-exists*)
                        [[ ! -e $filename ]]
                        ;;
                    *)
                        return 0
                        ;;
                esac
            }

            function autostart() {
              for application in $(list-autostart); do
                  if shouldAutostart "$application" ; then
                      (exec setsid /bin/sh -c "$(run-desktop "''${application}")" &>/dev/null &)
                  fi
              done
            }

            function list-autostart() {
              # Get locations of desktop application folders according to spec
              # https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
              IFS=':' read -ra DIRS <<<"''${XDG_CONFIG_HOME-${config.user.homeDirectory}/.config}:''${XDG_CONFIG_DIRS-/etc/xdg}"
              for i in "''${!DIRS[@]}"; do
                if [[ ! -d "''${DIRS[i]}" ]]; then
                  unset -v 'DIRS[$i]'
                else
                  DIRS[$i]="''${DIRS[i]}/autostart/*.desktop"
                fi
              done

              # shellcheck disable=SC2068
              awk -v pre="$GLYPH_DESKTOP" -F= '
                function desktopFileID(filename){
                  sub("^.*autostart/", "", filename);
                  sub("/", "-", filename);
                  return filename
                }
                BEGINFILE{
                  application=0;
                  block="";
                  disabled=0;
                  a=0

                  id=desktopFileID(FILENAME)
                  if(id in fileIds){
                    nextfile;
                  }else{
                    fileIds[id]=0
                  }
                }
                /^\[Desktop Entry\]/{block="entry"}
                /^Type=Application/{application=1}
                /^Name=/{ iname=$2 }
                /^Hidden=true/{disabled=1}
                ENDFILE{
                  if (application && !disabled){
                      print FILENAME;
                  }
                }' \
                ''${DIRS[@]} </dev/null
            }

            purge() {
             # shellcheck disable=SC2188
             > "''${HIST_FILE}"
             declare -A PURGE_CMDS
             for PROVIDER_NAME in "''${!PROVIDERS[@]}"; do
               readarray -td ''${DEL} PROVIDER_ARGS <<<''${PROVIDERS[''${PROVIDER_NAME}]}
               PURGE_CMD=''${PROVIDER_ARGS[3]}
               [ -z "''${PURGE_CMD}" ] && PURGE_CMD='test -f "{1}" || exit 43'
               PURGE_CMDS[$PROVIDER_NAME]="''${PURGE_CMD%$'\n'}"
              done
              for HIST_LINE in "''${HIST_LINES[@]#*' '}"; do
                readarray -td $'\034' HIST_ENTRY <<<''${HIST_LINE}
                ENTRY=''${HIST_ENTRY[1]}
                readarray -td ' ' FILTER <<<''${PURGE_CMDS[$ENTRY]//\{1\}/''${HIST_ENTRY[0]}}
                (eval "''${FILTER[@]}" 1>/dev/null) # Run filter command discarding output. We only want the exit status
                if [[ $? -ne 43 ]]; then
                  echo "1 ''${HIST_LINE[@]%$'\n'}" >> "''${HIST_FILE}"
                fi
              done
            }

            case "$1" in
            describe | describe-desktop | describe-command | entries | list-entries | list-commands | list-autostart | generate-command | autostart | run-desktop | provide | purge)
              "$@"
              exit
              ;;
            esac
            echo "Starting launcher instance with the following providers:" "''${!PROVIDERS[@]}" >&3

            FZFPIPE=$(mktemp -u)
            mkfifo "$FZFPIPE"
            trap 'rm "$FZFPIPE"' EXIT INT

            # Append Launcher History, removing usage count
            (printf '%s' "''${HIST_LINES[@]#* }" >>"$FZFPIPE") &

            # Iterate over providers and run their list-command
            for PROVIDER_NAME in "''${!PROVIDERS[@]}"; do
              (bash -c "''${0} provide ''${PROVIDER_NAME}" >>"$FZFPIPE") &
            done

            readarray -t COMMAND_STR <<<$(
              ''${FZF_COMMAND} --ansi +s -x -d '\034' --nth ..3 --with-nth 3 \
                --print-query \
                --preview "$0 describe {2} {1}" \
                --preview-window="''${PREVIEW_WINDOW}" \
                --no-multi --cycle \
                --prompt="''${GLYPH_PROMPT-# }" \
                --header="" --no-info --margin="1,2" \
                --color='16,gutter:-1' \
                <"$FZFPIPE"
            ) || exit 1
            # Get the last line of the fzf output. If there were no matches, it contains the query which we'll treat as a custom command
            # If there were matches, it contains the selected item
            COMMAND_STR=$(printf '%s\n' "''${COMMAND_STR[@]: -1}")
            # We still need to format the query to conform to our fallback provider.
            # We check for the presence of field separator character to determine if we're dealing with a custom command
            if [[ $COMMAND_STR != *$'\034'* ]]; then
                COMMAND_STR="''${COMMAND_STR}"$'\034user\034'"''${COMMAND_STR}"$'\034'
                SKIP_HIST=1 # I chose not to include custom commands in the history. If this is a bad idea, open an issue please
            fi

            [ -z "$COMMAND_STR" ] && exit 1

            if [[ -n "''${HIST_FILE}" && ! "$SKIP_HIST" ]]; then
              # update history
              for i in "''${!HIST_LINES[@]}"; do
                if [[ "''${HIST_LINES[i]}" == *" $COMMAND_STR"$'\n' ]]; then
                  HIST_COUNT=''${HIST_LINES[i]%% *}
                  HIST_LINES[$i]="$((HIST_COUNT + 1)) $COMMAND_STR"$'\n'
                  match=1
                  break
                fi
              done
              if ! ((match)); then
                HIST_LINES+=("1 $COMMAND_STR"$'\n')
              fi

              printf '%s' "''${HIST_LINES[@]}" | sort -nr >"$HIST_FILE"
            fi

            # shellcheck disable=SC2086
            readarray -d $'\034' -t PARAMS <<<''${COMMAND_STR}
            # shellcheck disable=SC2086
            readarray -d ''${DEL} -t PROVIDER_ARGS <<<''${PROVIDERS[''${PARAMS[1]}]}
            # Substitute {1}, {2} etc with the correct values
            COMMAND=''${PROVIDER_ARGS[2]//\{1\}/''${PARAMS[0]}}
            COMMAND=''${COMMAND//\{2\}/''${PARAMS[3]}}
            COMMAND=''${COMMAND%%[[:space:]]}

            if [ -t 1 ]; then
              echo "Launching command: ''${COMMAND}" >&3
              setsid /bin/sh -c "''${COMMAND}" >&/dev/null </dev/null &
              sleep 0.01
            else
              echo "''${COMMAND}"
            fi
          '';
        };
      };
    })
    # imv config already inlined in default.nix
    # mpv config already inlined in default.nix
    # pcmanfm config already inlined in default.nix
    # qbittorrent config already inlined in default.nix
    # stremio config already inlined in default.nix
    (lib.mkIf config.home.programs.bambu.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [bambu-studio];
    })
  ];
}
