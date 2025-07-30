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
      hjem.users.${config.user.name}.packages = with pkgs; [sway-launcher-desktop];
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
