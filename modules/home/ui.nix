{
  config,
  lib,
  pkgs,
  inputs,
  hostSystem,
  ...
}: let
  # Main UI component options
  agsCfg = config.home.ui.ags;
  cursorCfg = config.home.ui.cursor;
  fontsCfg = config.home.ui.fonts;
  footCfg = config.home.ui.foot;
  gtkCfg = config.home.ui.gtk;
  hyprlandCfg = config.home.ui.hyprland;
  makoCfg = config.home.ui.mako;
  niriCfg = config.home.ui.niri;
  qutebrowserCfg = config.home.ui.qutebrowser;
  wallustCfg = config.home.ui.wallust;
  quickshellCfg = config.home.ui.quickshell;
  waylandCfg = config.home.ui.wayland;

  username = config.user.name;
  inherit (config.home.core) defaults;

  # Cursor configuration
  hyprThemeName = "DeepinDarkV20-hypr";
  x11ThemeName = "DeepinDarkV20-x11";
  hyprcursorPackage = pkgs.phinger-cursors;
  xcursorPackage = pkgs.phinger-cursors;

  # Font configuration
  mainFontPackages = map (x: x.package) config.home.core.appearance.fonts.main;
  mainFontNames = map (x: x.name) config.home.core.appearance.fonts.main;
  fallbackPackages = map (x: x.package) config.home.core.appearance.fonts.fallback;
  fallbackNames = map (x: x.name) config.home.core.appearance.fonts.fallback;
  fontXmlConfig = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <!-- Disable all fonts by default -->
      <selectfont>
        <rejectfont>
          <pattern>
            <patelt name="family">
              <string>*</string>
            </patelt>
          </pattern>
        </rejectfont>
      </selectfont>
      <!-- Explicitly enable only our chosen fonts -->
      <selectfont>
        <acceptfont>
          <pattern>
            <patelt name="family">
              <string>${builtins.elemAt mainFontNames 0}</string>
            </patelt>
          </pattern>
          ${lib.concatMapStrings (name: ''
        <pattern>
          <patelt name="family">
            <string>${name}</string>
          </patelt>
        </pattern>
      '')
      fallbackNames}
        </acceptfont>
      </selectfont>
      <!-- Set main font as default -->
      <match>
        <test name="family">
          <string>*</string>
        </test>
        <edit name="family" mode="prepend">
          <string>${builtins.elemAt mainFontNames 0}</string>
        </edit>
      </match>
      <!-- Fallback font configuration -->
      <alias>
        <family>monospace</family>
        <prefer>
          <family>${builtins.elemAt mainFontNames 0}</family>
          ${lib.concatMapStrings (name: "<family>${name}</family>") fallbackNames}
        </prefer>
      </alias>
      <!-- Font rendering options -->
      <match target="font">
        <edit name="antialias" mode="assign"><bool>true</bool></edit>
        <edit name="hinting" mode="assign"><bool>true</bool></edit>
        <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
        <edit name="rgba" mode="assign"><const>rgb</const></edit>
        <edit name="autohint" mode="assign"><bool>true</bool></edit>
        <edit name="lcdfilter" mode="assign"><const>lcdlight</const></edit>
        <edit name="dpi" mode="assign"><double>${toString config.home.core.appearance.dpi}</double></edit>
      </match>
    </fontconfig>
  '';

  # Foot terminal configuration
  computedFontSize = toString (config.home.core.appearance.baseFontSize * 1.33);
  mainFontName = (builtins.elemAt config.home.core.appearance.fonts.main 0).name;
  fallbackFontNames = map (x: x.name) config.home.core.appearance.fonts.fallback;
  mainFontConfig =
    "${mainFontName}:size=${computedFontSize}, "
    + lib.concatStringsSep ", " (map (name: "${name}:size=${computedFontSize}") fallbackFontNames);
  footConfig = {
    main = {
      term = "xterm-256color";
      font = mainFontConfig;
      dpi-aware = "yes";
    };
    cursor = {
      style = "underline";
      blink = "no";
    };
    mouse = {
      hide-when-typing = "no";
      alternate-scroll-mode = "yes";
    };
    colors = {
      alpha = 0;
      background = "000000";
      foreground = "ffffff";
      regular0 = "000000";
      regular1 = "ff0000";
      regular2 = "00ff00";
      regular3 = "ffff00";
      regular4 = "1e90ff";
      regular5 = "ff00ff";
      regular6 = "00ffff";
      regular7 = "ffffff";
      bright0 = "808080";
      bright1 = "ff0000";
      bright2 = "00ff00";
      bright3 = "ffff00";
      bright4 = "1e90ff";
      bright5 = "ff00ff";
      bright6 = "00ffff";
      bright7 = "ffffff";
    };
    key-bindings = {
      clipboard-copy = "Control+c XF86Copy";
      clipboard-paste = "Control+v XF86Paste";
    };
  };

  # GTK configuration
  mainFontNameGtk = (builtins.elemAt config.home.core.appearance.fonts.main 0).name;
  inherit (config.home.core.appearance) baseFontSize;
  dpiStr = toString config.home.core.appearance.dpi;
  inherit (config.home.core.user) bookmarks;
  scaleFactor = gtkCfg.scale;
  shadowSize = "0.05rem";
  shadowRadius = "0.05rem";
  shadowColor = "rgba(0, 0, 0, 0.3)";
  shadowOffsets = [
    "${shadowSize} 0 ${shadowRadius} ${shadowColor}"
    "-${shadowSize} 0 ${shadowRadius} ${shadowColor}"
    "0 ${shadowSize} ${shadowRadius} ${shadowColor}"
    "0 -${shadowSize} ${shadowRadius} ${shadowColor}"
    "${shadowSize} ${shadowSize} ${shadowRadius} ${shadowColor}"
    "-${shadowSize} ${shadowSize} ${shadowRadius} ${shadowColor}"
    "${shadowSize} -${shadowSize} ${shadowRadius} ${shadowColor}"
    "-${shadowSize} -${shadowSize} ${shadowRadius} ${shadowColor}"
  ];
  repeatedShadow = lib.concatStringsSep ",\n" (lib.concatLists (lib.genList (_: shadowOffsets) 4));
  whiteColor = "white";
  transparentColor = "transparent";
  menuBackground = "rgba(0, 0, 0, 0.8)";
  hoverBg = "rgba(100, 149, 237, 0.1)";
  selectedBg = "rgba(100, 149, 237, 0.5)";
  gtk3Settings = {
    Settings = {
      gtk-application-prefer-dark-theme = 1;
      gtk-cursor-theme-name = "DeepinDarkV20-x11";
      gtk-cursor-theme-size = toString (builtins.floor (24 * scaleFactor));
      gtk-font-name = "${mainFontNameGtk} ${toString baseFontSize}";
      gtk-xft-antialias = 1;
      gtk-xft-dpi = dpiStr;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };
  };
  gtk4Settings = {
    Settings = {
      gtk-application-prefer-dark-theme = 1;
      gtk-cursor-theme-name = "DeepinDarkV20-x11";
      gtk-cursor-theme-size = toString (builtins.floor (24 * scaleFactor));
      gtk-font-name = "${mainFontNameGtk} ${toString baseFontSize}";
    };
  };
  gtkCss = ''
    /* Global element styling */
    * {
      font-family: "${mainFontNameGtk}";
      color: ${whiteColor};
      background: ${transparentColor};
      outline-width: 0;
      outline-offset: 0;
      text-shadow: ${repeatedShadow};
    }
    /* Hover state for all elements */
    *:hover {
      background: ${hoverBg};
    }
    /* Selected state for all elements */
    *:selected {
      background: ${selectedBg};
    }
    /* Button styling */
    button {
      border-radius: 0.15rem;
      min-height: 1rem;
      padding: 0.05rem 0.25rem;
    }
    /* Menu background styling */
    menu {
      background: ${menuBackground};
    }
  '';
  bookmarksContent = lib.concatStringsSep "\n" bookmarks;

  # Hyprland toHyprconf generator functions
  generators = let
    inherit
      (builtins)
      all
      isAttrs
      isList
      removeAttrs
      ;
    inherit (lib.attrsets) filterAttrs mapAttrsToList;
    inherit (lib.generators) toKeyValue;
    inherit (lib.lists) foldl replicate;
    inherit
      (lib.strings)
      concatStrings
      concatStringsSep
      concatMapStringsSep
      hasPrefix
      ;
    inherit (lib.types) package;
    sectionOrderingRules = {
      animations = ["bezier" "animation"];
    };
    toHyprconf = {
      attrs,
      indentLevel ? 0,
      importantPrefixes ? ["$"],
    }: let
      initialIndent = concatStrings (replicate indentLevel "  ");
      toHyprconf' = indent: attrs: let
        sections = filterAttrs (_: v: isAttrs v || (isList v && all isAttrs v)) attrs;
        mkSection = n: attrs:
          if isList attrs
          then (concatMapStringsSep "\n" (a: mkSection n a) attrs)
          else let
            hasOrderingRules = builtins.hasAttr n sectionOrderingRules;
            processedAttrs =
              if hasOrderingRules
              then let
                orderingRule = sectionOrderingRules.${n};
                allKeys = builtins.attrNames attrs;
                orderedKeys = builtins.filter (key: builtins.elem key orderingRule) allKeys;
                unorderedKeys = builtins.filter (key: !(builtins.elem key orderingRule)) allKeys;
                sortedOrderedKeys = builtins.filter (ruleKey: builtins.elem ruleKey orderedKeys) orderingRule;
                finalKeyOrder = sortedOrderedKeys ++ unorderedKeys;
                orderedAttrs = lib.listToAttrs (map (key: {
                    name = key;
                    value = attrs.${key};
                  })
                  finalKeyOrder);
              in
                orderedAttrs
              else attrs;
          in ''
            ${indent}${n} {
            ${toHyprconf' "  ${indent}" processedAttrs}${indent}}
          '';
        mkFields = toKeyValue {
          listsAsDuplicateKeys = true;
          inherit indent;
        };
        allFields = filterAttrs (_: v: !(isAttrs v || (isList v && all isAttrs v))) attrs;
        isImportantField = n: _:
          foldl (acc: prev:
            if hasPrefix prev n
            then true
            else acc)
          false
          importantPrefixes;
        isEarlyField = n: _: n == "bezier";
        importantFields = filterAttrs isImportantField allFields;
        earlyFields = filterAttrs isEarlyField (removeAttrs allFields (mapAttrsToList (n: _: n) importantFields));
        regularFields = removeAttrs allFields (mapAttrsToList (n: _: n) (importantFields // earlyFields));
      in
        mkFields importantFields
        + mkFields earlyFields
        + concatStringsSep "\n" (mapAttrsToList mkSection sections)
        + mkFields regularFields;
    in
      toHyprconf' initialIndent attrs;
    pluginsToHyprconf = plugins: importantPrefixes:
      toHyprconf {
        attrs = {
          plugin = let
            mkEntry = entry:
              if package.check entry
              then "${entry}/lib/lib${entry.pname}.so"
              else entry;
          in
            map mkEntry plugins;
        };
        inherit importantPrefixes;
      };
  in {
    inherit toHyprconf pluginsToHyprconf;
  };

  # Hyprland core configuration
  hyprlandCoreConfig = {
    "$active_colour" = "ffffffff";
    "$transparent" = "ffffff00";
    "$inactive_colour" = "333333ff";
    general = {
      gaps_in = 10;
      gaps_out = 5;
      border_size = 1;
      "col.active_border" = "rgba($active_colour)";
      "col.inactive_border" = "rgba($inactive_colour)";
      layout =
        if hyprlandCfg.hy3.enable
        then "hy3"
        else if hyprlandCfg.group.enable
        then "group"
        else "dwindle";
    };
    dwindle = {
      single_window_aspect_ratio = "1.77 1.0";
      single_window_aspect_ratio_tolerance = 0.1;
    };
    input = {
      kb_layout = "us";
      follow_mouse = 1;
      sensitivity = -1.0;
      force_no_accel = true;
      mouse_refocus = false;
    };
    decoration = {
      rounding = 0;
      blur = {
        enabled = true;
        size = 10;
        passes = 3;
        ignore_opacity = true;
        popups = true;
      };
    };
    render = {
      cm_enabled = 0;
    };
    bezier = [
      "in-out,.65,-0.01,0,.95"
      "woa,0,0,0,1"
    ];
    animations = {
      enabled =
        if config.home.core.appearance.animations.enable
        then 1
        else 0;
      animation = [
        "windows,1,2,woa,popin"
        "border,1,10,default"
        "fade,1,10,default"
        "workspaces,1,5,in-out,slide"
      ];
    };
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };
    debug.disable_logs = false;
    env =
      [
        "HYPRCURSOR_THEME,DeepinDarkV20-hypr"
        "HYPRCURSOR_SIZE,${toString config.home.core.appearance.cursorSize}"
        "XCURSOR_THEME,DeepinDarkV20-x11"
        "XCURSOR_SIZE,${toString config.home.core.appearance.cursorSize}"
      ]
      ++ lib.optionals hostSystem.hardware.nvidia.enable [
        "LIBVA_DRIVER_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];
  };

  # Hyprland keybindings configuration
  hyprlandKeybindingsConfig = {
    "$mod" = "ALT";
    "$mod2" = "SUPER";
    "$term" = defaults.terminal;
    "$filemanager" = defaults.fileManager;
    "$browser" = defaults.browser;
    "$discord" = defaults.discord;
    "$launcher" = defaults.launcher;
    "$ide" = defaults.ide;
    "$notepad" = "${defaults.terminal} -e ${defaults.editor}";
    "$obs" = "obs";
    bind = lib.lists.flatten [
      (lib.optional hyprlandCfg.group.enable "$mod CTRL, G, togglegroup")
      (lib.optional hyprlandCfg.group.enable "$mod CTRL SHIFT, G, lockgroups, toggle")
      (lib.optional hyprlandCfg.group.enable "$mod CTRL, J, changegroupactive, b")
      (lib.optional hyprlandCfg.group.enable "$mod CTRL, K, changegroupactive, f")
      (lib.optional hyprlandCfg.group.enable "$mod CTRL SHIFT, J, moveintogroup, b")
      (lib.optional hyprlandCfg.group.enable "$mod CTRL SHIFT, K, moveintogroup, f")
      (lib.optional hyprlandCfg.group.enable "$mod CTRL, H, moveoutofgroup")
      [
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, F, fullscreen"
        "$mod, TAB, layoutmsg, orientationnext"
        "$mod, space, togglefloating"
        "$mod, P, pseudo"
      ]
      [
        "$mod, T, exec, $term"
        "$mod, E, exec, $filemanager"
        "$mod, R, exec, $launcher"
        "$mod, O, exec, $notepad"
        "$mod, 1, exec, $ide"
        "$mod, 2, exec, $browser"
        "$mod, 3, exec, vesktop"
        "$mod, 4, exec, steam"
        "$mod, 5, exec, $obs"
      ]
      [
        "$mod SHIFT, S, swapactiveworkspaces, DP-4 HDMI-A-2"
        "$mod, S, movecurrentworkspacetomonitor, +1"
      ]
      (lib.lists.forEach ["h" "j" "k" "l"] (key: let
        direction =
          {
            "k" = "u";
            "h" = "l";
            "j" = "d";
            "l" = "r";
          }
          .${
            key
          };
      in [
        "$mod, ${key}, movefocus, ${direction}"
        "$mod SHIFT, ${key}, movewindow, ${direction}"
      ]))
      (lib.lists.forEach (lib.range 1 9) (i: let
        num = toString i;
      in [
        "$mod2, ${num}, workspace, ${num}"
        "$mod2 SHIFT, ${num}, movetoworkspacesilent, ${num}"
      ]))
      [
        "Ctrl$mod2,Delete, exec, gnome-system-monitor"
        "$mod Shift, M, exec, shutdown now"
        "Ctrl$mod2Shift, M, exec, reboot"
        "Ctrl,Period,exec,smile"
      ]
      [
        "$mod, G, exec, grim -g \"$(slurp -d)\" - | wl-copy -t image/png"
        "$mod SHIFT, G, exec, grim - | wl-copy -t image/png"
        "$mod, GRAVE, exec, hyprpicker | wl-copy"
      ]
      [
        "$mod SHIFT, C, exec, killall swaybg; for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do wall=$(find ${config.home.directories.wallpapers.static.path} -type f | shuf -n 1); swaybg -o $monitor -i $wall -m fill & done"
      ]
    ];
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];
  };

  # Hyprland integrations configuration
  agsEnabled = config.home.ui.ags.enable or false;
  quickshellEnabled = config.home.ui.quickshell.enable or false;
  hyprlandIntegrationsConfig = {
    # Monitor configuration
    monitor = [
      "DP-4,highres@highrr,0x0,1"
      "DP-3,highres@highrr,0x0,1"
      "DP-2,5120x1440@239.76,0x0,1"
      "DP-1,5120x1440@239.76,0x0,1"
      "eDP-1,1920x1080@300.00,0x0,1"
    ];

    # Window rules and layer rules
    "$firefox-pip" = "class:^(firefox)$, title:^(Picture-in-Picture)";
    "$kitty" = "class:^(kitty)$";
    windowrulev2 = [
      "float, center, size 300 600, class:^(launcher)"
      "float, center, class:^(hyprland-share-picker)"
      "float, $firefox-pip"
      "opacity 0.75 override, $firefox-pip"
      "noborder, $firefox-pip"
      "size 30% 30%, $firefox-pip"
      "workspace special:lovely, title:^(Lovely.*)"
    ];
    layerrule = [
      "blur, notifications"
    ];

    # Exec-once integrations
    "exec-once" =
      lib.optionals agsEnabled [
        "exec ags run"
      ]
      ++ lib.optionals quickshellEnabled [
        "exec quickshell"
      ]
      ++ [
        # Initial wallpaper setup
        "for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do wall=$(find ${config.home.directories.wallpapers.static.path} -type f | shuf -n 1); swaybg -o $monitor -i $wall -m fill & done"
      ];

    # Keybindings
    bind =
      lib.optionals agsEnabled [
        "$mod, W, exec, ags request showStats"
        "$mod2, TAB, exec, ags request toggleWorkspaces"
      ]
      ++ lib.optionals quickshellEnabled [
        "$mod2, TAB, exec, quickshell ipc call workspaces toggle"
      ];

    bindr = lib.optionals agsEnabled [
      "$mod, W, exec, ags request hideStats"
    ];
  };
in {
  options.home.ui = {
    # AGS options
    ags = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable AGS v2 (Astal Framework)";
      };
    };

    # Cursor options
    cursor = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable cursor theme configuration";
      };
    };

    # Fonts options
    fonts = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable font configuration with string substitution";
      };
    };

    # Foot options
    foot = {
      enable = lib.mkEnableOption "foot terminal emulator";
    };

    # GTK options
    gtk = {
      enable = lib.mkEnableOption "GTK theming and configuration using hjem";
      scale = lib.mkOption {
        type = lib.types.float;
        default = 1.0;
        description = "Scaling factor for GTK applications (e.g., 1.0, 1.25, 1.5, 2.0)";
        example = 1.5;
      };
    };

    # Hyprland options
    hyprland = {
      enable = lib.mkEnableOption "Hyprland window manager";
      flake = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to use Hyprland from flake inputs instead of nixpkgs";
        };
      };
      hy3 = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable the hy3 tiling layout plugin";
        };
      };
      group = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to enable the group layout mode";
        };
      };
    };

    # Mako options
    mako = {
      enable = lib.mkEnableOption "Mako notification daemon";
    };

    # Niri options
    niri = {
      enable = lib.mkEnableOption "Niri window manager";
    };

    # Qutebrowser options
    qutebrowser = {
      enable = lib.mkEnableOption "qutebrowser web browser";
    };

    # Wayland tools options
    wallust.enable = lib.mkEnableOption "wallust color generation";

    quickshell.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Quickshell desktop shell";
    };

    wayland.enable = lib.mkEnableOption "Wayland configuration";
  };

  config = lib.mkMerge [
    # AGS configuration
    (lib.mkIf agsCfg.enable {
      hjem.users.${username} = {
        packages = [
          pkgs.ags
        ];
        files = {
          ".config/ags/app.tsx" = {
            clobber = true;
            text = ''
              import { App, Astal, Gtk } from "astal/gtk3"
              import { Variable, exec, subprocess } from "astal"
              // ============================================================================
              // UTILITY FUNCTIONS
              // ============================================================================
              // Safe command execution helper for AGS v2
              function safeExec(command: string, defaultValue: string = 'N/A'): string {
                  try {
                      const result = exec(["bash", "-c", command]);
                      return result.trim() || defaultValue;
                  } catch (error) {
                      console.log(`Failed to execute command: ''${command}`, error);
                      return defaultValue;
                  }
              }
              // Timer-based time updates (more efficient than polling)
              function setupTimeUpdates(currentTime: any, currentDate: any) {
                  const updateTime = () => {
                      currentTime.set(safeExec('date "+%H:%M:%S"'));
                  };
                  const updateDate = () => {
                      currentDate.set(safeExec('date "+%d/%m/%y"'));
                  };
                  // Update immediately
                  updateTime();
                  updateDate();
                  // Update time every second using setTimeout instead of polling
                  const timeInterval = setInterval(updateTime, 1000);
                  // Update date at midnight and then every 24 hours
                  const now = new Date();
                  const tomorrow = new Date(now);
                  tomorrow.setDate(tomorrow.getDate() + 1);
                  tomorrow.setHours(0, 0, 0, 0);
                  const msUntilMidnight = tomorrow.getTime() - now.getTime();
                  setTimeout(() => {
                      updateDate();
                      // Then update every 24 hours
                      setInterval(updateDate, 24 * 60 * 60 * 1000);
                  }, msUntilMidnight);
              }
              // Event-driven package count monitoring
              function setupPackageMonitoring(packageCount: any) {
                  const updatePackageCount = () => {
                      const count = safeExec("which nix-store >/dev/null 2>&1 && nix-store -q --requisites /run/current-system/sw 2>/dev/null | wc -l || echo 'N/A'").trim();
                      packageCount.set(count);
                  };
                  updatePackageCount();
                  // Monitor for system rebuilds and package operations
                  subprocess([
                      "bash",
                      "-c",
                      `
                      while true; do
                          inotifywait -e modify,create,delete /nix/var/nix/profiles/system* 2>/dev/null || sleep 30
                          echo "package_change"
                      done
                      `
                  ], (output: string) => {
                      if (output.includes('package_change')) {
                          updatePackageCount();
                      }
                  });
              }
              // Helper functions for SystemStats component
              function padLabel(label: string, longestLabel: number): string {
                  return label + ' '.repeat(longestLabel - label.length);
              }
              function horizontalBorder(char1: string, char2: string, char3: string, longestLabel: number): string {
                  return char1 + "─".repeat(longestLabel + 4) + char3;
              }
              // Cache GPU availability check
              const hasNvidiaGpu = (() => {
                  try {
                      exec(["bash", "-c", "which nvidia-smi >/dev/null 2>&1"]);
                      return true;
                  } catch {
                      return false;
                  }
              })();
              // ============================================================================
              // STYLES
              // ============================================================================
              const styles = `
              /* Base font size */
              * {
                  font-size: 14px;
                  font-family: monospace;
              }
              /* System Stats Widget Styles */
              .system-stats-window {
                  background: transparent;
              }
              .system-stats {
                  background: transparent;
                  padding: 0.5em;
                  margin: 0.5em;
                  font-family: monospace;
                  font-size: 1rem;
              }
              .system-stats * {
                  margin: 0;
                  padding: 0;
                  background: transparent;
                  border: none;
                  box-shadow: none;
                  text-shadow:
                      0.05rem 0 0.05rem
                      -0.05rem 0 0.05rem
                      0 0.05rem 0.05rem
                      0 -0.05rem 0.05rem
                      0.05rem 0.05rem 0.05rem
                      -0.05rem 0.05rem 0.05rem
                      0.05rem -0.05rem 0.05rem
                      -0.05rem -0.05rem 0.05rem
                  font-family: inherit;
                  font-size: inherit;
                  font-weight: inherit;
                  color: inherit;
              }
              /* Rainbow color assignments */
              .stats-time { color:
              .stats-date { color:
              .stats-shell { color:
              .stats-uptime { color:
              .stats-pkgs { color:
              .stats-memory { color:
              .stats-cpu { color:
              .stats-gpu { color:
              .stats-colors { color:
              .stats-white { color:
              .stats-red { color:
              .stats-orange { color:
              .stats-yellow { color:
              .stats-green { color:
              .stats-blue-green { color:
              .stats-cyan { color:
              .stats-blue { color:
              .stats-magenta { color:
              /* Workspaces Widget Styles */
              .workspaces-top, .workspaces-bottom {
                  background: transparent;
              }
              .workspaces {
                  background: transparent;
                  margin: 0;
                  padding: 0;
              }
              .workspaces *,
              .workspaces {
                  margin: 0;
                  padding: 0;
                  background: transparent;
                  border: none;
                  box-shadow: none;
                  color: white;
              }
              .workspace-btn {
                  margin: 0;
                  padding: 0;
                  background-color:
                  border-radius: 0;
                  min-width: 20px;
                  min-height: 20px;
              }
              .workspace-btn label {
                  background: transparent;
                  color: rgba(255, 255, 255, 0.4);
                  font-size: 0.8rem;
                  padding: 0.25em;
              }
              .workspace-btn.active label {
                  color: rgba(255, 255, 255, 1.0);
              }
              .workspace-btn.occupied label {
                  color: rgba(255, 255, 255, 0.8);
              }
              .workspace-btn.inactive label {
                  color: rgba(255, 255, 255, 0.5);
              }
              .workspace-btn.urgent label {
                  color:
              }
              `
              // ============================================================================
              // SYSTEM STATS MODULE
              // ============================================================================
              // Show/hide control variables
              const systemStatsVisible = Variable(true);
              const systemStatsLayer = Variable(Astal.Layer.BOTTOM);
              // System monitoring variables with optimized polling intervals
              const cpuTemp = Variable('N/A').poll(250, () => {
                  return safeExec("sensors 2>/dev/null | grep -E 'Tctl|Package id 0' | head -1 | awk '{print $2}' | sed 's/+//' || echo 'N/A'");
              });
              const gpuTemp = Variable('N/A').poll(250, () => {
                  if (!hasNvidiaGpu) return 'N/A';
                  const temp = safeExec("nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo 'N/A'");
                  return temp !== "N/A" && temp !== "" ? temp + "C" : "N/A";
              });
              const memoryInfo = Variable({ used: 'N/A', total: 'N/A' }).poll(2000, () => {
                  try {
                      const output = exec(["bash", "-c", "free -h | grep '^Mem:' | awk '{print $3 \"/\" $2}'"]);
                      const parts = output.trim().split('/');
                      return { used: parts[0] || 'N/A', total: parts[1] || 'N/A' };
                  } catch {
                      return { used: 'N/A', total: 'N/A' };
                  }
              });
              const uptime = Variable('N/A').poll(60000, () => {
                  return safeExec("uptime | sed 's/.*up *//' | sed 's/,.*user.*//' | sed 's/^ *//' | sed 's/ *$//' | sed 's/ day/d/' | sed 's/ days/d/'").trim();
              });
              // Timer-based time updates
              const currentTime = Variable('00:00:00');
              const currentDate = Variable('00/00/00');
              // Event-driven package count
              const packageCount = Variable('N/A');
              // Shell name never changes during session - set once
              const shellName = Variable(safeExec("basename \"$SHELL\""));
              // Initialize monitoring
              setupTimeUpdates(currentTime, currentDate);
              setupPackageMonitoring(packageCount);
              // Static data for SystemStats component (moved outside to prevent recreation)
              const statsLabels = ['time', 'date', 'shell', 'uptime', 'pkgs', 'memory', 'cpu', 'gpu', 'colors'];
              const longestLabel = Math.max(...statsLabels.map(l => l.length));
              // System Stats Widget Component
              function SystemStats() {
                  return <window
                      className="system-stats-window"
                      layer={systemStatsLayer()}
                      exclusivity={Astal.Exclusivity.IGNORE}
                      visible={systemStatsVisible()}
                      application={App}>
                      <box className="system-stats" vertical>
                          {/* NixOS Logo */}
                          <label
                              className="stats-white"
                              label="   _  ___      ____  ____&
                          />
                          {/* Top border */}
                          <label
                              className="stats-white"
                              halign={Gtk.Align.START}
                              label={horizontalBorder("╭", "─", "╮", longestLabel)}
                          />
                          {/* Stats rows */}
                          {statsLabels.map(currentLabel =>
                              <box key={currentLabel}>
                                  <label className="stats-white" halign={Gtk.Align.START} label="│ " />
                                  <label className={`stats-''${currentLabel}`} halign={Gtk.Align.START} label="• " />
                                  <label className="stats-white" halign={Gtk.Align.START} label={`''${padLabel(currentLabel, longestLabel)} │ `} />
                                  <label
                                      className={`stats-''${currentLabel}`}
                                      halign={Gtk.Align.START}
                                      label={(() => {
                                          switch(currentLabel) {
                                              case 'time': return currentTime();
                                              case 'date': return currentDate();
                                              case 'shell': return shellName();
                                              case 'uptime': return uptime();
                                              case 'pkgs': return packageCount();
                                              case 'memory': return `''${memoryInfo.get().used}/''${memoryInfo.get().total}`;
                                              case 'cpu': return cpuTemp();
                                              case 'gpu': return gpuTemp();
                                              case 'colors': return "";
                                              default: return "";
                                          }
                                      })()}
                                  />
                                  {/* Color dots for colors row */}
                                  {currentLabel === 'colors' && [
                                      <label key="red" className="stats-red" label="• " />,
                                      <label key="orange" className="stats-orange" label="• " />,
                                      <label key="yellow" className="stats-yellow" label="• " />,
                                      <label key="green" className="stats-green" label="• " />,
                                      <label key="blue-green" className="stats-blue-green" label="• " />,
                                      <label key="cyan" className="stats-cyan" label="• " />,
                                      <label key="blue" className="stats-blue" label="• " />,
                                      <label key="magenta" className="stats-magenta" label="• " />,
                                      <label key="white" className="stats-white" label="• " />
                                  ]}
                              </box>
                          )}
                          {/* Bottom border */}
                          <label
                              className="stats-white"
                              halign={Gtk.Align.START}
                              label={horizontalBorder("╰", "─", "╯", longestLabel)}
                          />
                      </box>
                  </window>
              }
              // ============================================================================
              // WORKSPACES MODULE
              // ============================================================================
              // Show/hide control variable
              const workspacesVisible = Variable(true);
              // Hyprland workspace management with real-time events
              const workspaces = Variable<any[]>([]);
              const activeWorkspace = Variable<number>(1);
              // Create a single derived variable for workspace state to optimize subscriptions
              const workspaceState = Variable.derive([workspaces, activeWorkspace], (ws, active) => ({
                  workspaces: ws,
                  activeWorkspace: active
              }));
              // Helper function to switch workspace using hyprctl
              function switchWorkspace(workspaceId: number) {
                  try {
                      exec(["hyprctl", "dispatch", "workspace", workspaceId.toString()]);
                  } catch (error) {
                      console.error("Failed to switch workspace:", error);
                  }
              }
              // Initialize workspace data
              function initializeWorkspaces() {
                  try {
                      const output = exec(["bash", "-c", "hyprctl workspaces -j 2>/dev/null || echo '[]'"]);
                      workspaces.set(JSON.parse(output));
                  } catch {
                      workspaces.set([]);
                  }
                  try {
                      const output = exec(["bash", "-c", "hyprctl activeworkspace -j 2>/dev/null || echo '{\"id\":1}'"]);
                      const parsed = JSON.parse(output);
                      activeWorkspace.set(parsed.id || 1);
                  } catch {
                      activeWorkspace.set(1);
                  }
              }
              // Update workspace list when needed
              function updateWorkspaceList() {
                  try {
                      const output = exec(["bash", "-c", "hyprctl workspaces -j 2>/dev/null || echo '[]'"]);
                      workspaces.set(JSON.parse(output));
                  } catch {
                      // Keep existing workspaces if update fails
                  }
              }
              // Set up real-time Hyprland event monitoring
              function setupHyprlandEvents() {
                  const hyprlandSignature = exec(["bash", "-c", "echo $HYPRLAND_INSTANCE_SIGNATURE"]).trim();
                  if (!hyprlandSignature) {
                      console.error("HYPRLAND_INSTANCE_SIGNATURE not found - not running under Hyprland");
                      return;
                  }
                  // Get current user ID dynamically for portability
                  const userId = exec(["bash", "-c", "id -u"]).trim();
                  const socketPath = `/run/user/''${userId}/hypr/''${hyprlandSignature}/.socket2.sock`;
                  // Real-time event monitoring using nc
                  subprocess([
                      "bash",
                      "-c",
                      `nc -U "''${socketPath}" 2>/dev/null || { echo "Failed to connect to Hyprland socket"; exit 1; }`
                  ], (output) => {
                      const lines = output.split('\\n').filter(line => line.trim());
                      for (const line of lines) {
                          if (line.startsWith('workspace>>')) {
                              // Active workspace changed
                              const workspaceId = parseInt(line.split('>>')[1]) || 1;
                              activeWorkspace.set(workspaceId);
                          }
                          else if (line.startsWith('createworkspace>>')) {
                              // New workspace created
                              updateWorkspaceList();
                          }
                          else if (line.startsWith('destroyworkspace>>')) {
                              // Workspace destroyed
                              updateWorkspaceList();
                          }
                          else if (line.startsWith('openwindow>>') || line.startsWith('closewindow>>')) {
                              // Window opened/closed - might affect workspace occupancy
                              updateWorkspaceList();
                          }
                      }
                  });
              }
              // Initialize workspaces and start event monitoring
              initializeWorkspaces();
              setupHyprlandEvents();
              // Workspaces Widget Component
              function WorkspacesWidget(position: 'top' | 'bottom') {
                  const anchor = position === 'top'
                      ? Astal.WindowAnchor.TOP
                      : Astal.WindowAnchor.BOTTOM;
                  // Create workspace buttons (1-10 like in v1 config)
                  const workspaceButtons = Array.from({ length: 10 }, (_, i) => {
                      const workspaceId = i + 1;
                      return <button
                          key={workspaceId}
                          className="workspace-btn"
                          onClicked={() => {
                              switchWorkspace(workspaceId);
                          }}
                          setup={(self) => {
                              // Function to update button state
                              const updateButton = () => {
                                  const state = workspaceState.get();
                                  const ws = state.workspaces;
                                  const active = state.activeWorkspace;
                                  const isActive = active === workspaceId;
                                  const isOccupied = Array.isArray(ws) && ws.some((workspace: any) =>
                                      workspace.id === workspaceId && workspace.windows > 0
                                  );
                                  // Show button if it's active or occupied, or if it's workspace 1 (always show)
                                  self.visible = isActive || isOccupied || workspaceId === 1;
                                  // Update CSS classes
                                  self.className = `workspace-btn ''${isActive ? "active" : ""} ''${isOccupied && !isActive ? "occupied" : ""}`.trim();
                              };
                              // Initial update
                              updateButton();
                              // Subscribe to single workspace state variable instead of two separate ones
                              workspaceState.subscribe(updateButton);
                          }}>
                          <label label={workspaceId.toString()} />
                      </button>
                  });
                  return <window
                      className={`workspaces-''${position}`}
                      layer={Astal.Layer.OVERLAY}
                      exclusivity={Astal.Exclusivity.IGNORE}
                      anchor={anchor}
                      visible={workspacesVisible()}
                      application={App}>
                      <box className="workspaces">
                          {workspaceButtons}
                      </box>
                  </window>
              }
              // ============================================================================
              // MAIN APPLICATION
              // ============================================================================
              // Main app configuration
              App.start({
                  css: styles,
                  requestHandler(request: string, ...args: any[]) {
                      switch (request) {
                          case "showStats":
                              systemStatsVisible.set(true);
                              systemStatsLayer.set(Astal.Layer.TOP);
                              return "Stats shown";
                          case "hideStats":
                              systemStatsLayer.set(Astal.Layer.BOTTOM);
                              return "Stats hidden";
                          case "toggleStats":
                              if (systemStatsLayer.get() === Astal.Layer.TOP) {
                                  systemStatsLayer.set(Astal.Layer.BOTTOM);
                              } else {
                                  systemStatsVisible.set(true);
                                  systemStatsLayer.set(Astal.Layer.TOP);
                              }
                              return "Stats toggled";
                          case "showWorkspaces":
                              workspacesVisible.set(true);
                              return "Workspaces shown";
                          case "hideWorkspaces":
                              workspacesVisible.set(false);
                              return "Workspaces hidden";
                          case "toggleWorkspaces":
                              workspacesVisible.set(!workspacesVisible.get());
                              return "Workspaces toggled";
                          default:
                              return `Unknown request: ''${request}`;
                      }
                  },
                  main() {
                      // Create system stats window
                      SystemStats();
                      // Create workspace widgets
                      WorkspacesWidget('top');
                      WorkspacesWidget('bottom');
                  },
              })
            '';
          };
          ".config/ags/tsconfig.json" = {
            clobber = true;
            text = ''
              {
                "compilerOptions": {
                  "target": "ES2022",
                  "module": "ES2022",
                  "lib": ["ES2022"],
                  "allowJs": true,
                  "strict": true,
                  "esModuleInterop": true,
                  "skipLibCheck": true,
                  "forceConsistentCasingInFileNames": true,
                  "moduleResolution": "node",
                  "jsx": "react-jsx",
                  "jsxImportSource": "astal/gtk3/jsx-runtime"
                },
                "include": ["**/*.ts", "**/*.tsx"],
                "exclude": ["node_modules"]
              }
            '';
          };
        };
      };
    })

    # Cursor configuration
    (lib.mkIf cursorCfg.enable {
      hjem.users.${username} = {
        packages = with pkgs; [
          hyprcursorPackage
          xcursorPackage
        ];
        files = {
          ".profile" = {
            text = lib.mkAfter ''
              export HYPRCURSOR_THEME="${hyprThemeName}"
              export HYPRCURSOR_SIZE="${toString config.home.core.appearance.cursorSize}"
              export XCURSOR_THEME="${x11ThemeName}"
              export XCURSOR_SIZE="${toString config.home.core.appearance.cursorSize}"
            '';
            clobber = true;
          };
          ".config/gtk-3.0/settings.ini" = {
            text = lib.mkAfter ''
              [Settings]
              gtk-cursor-theme-name=${x11ThemeName}
              gtk-cursor-theme-size=${toString config.home.core.appearance.cursorSize}
            '';
            clobber = true;
          };
          ".config/gtk-4.0/settings.ini" = {
            text = lib.mkAfter ''
              [Settings]
              gtk-cursor-theme-name=${x11ThemeName}
              gtk-cursor-theme-size=${toString config.home.core.appearance.cursorSize}
            '';
            clobber = true;
          };
        };
      };
    })

    # Fonts configuration
    (lib.mkIf fontsCfg.enable {
      hjem.users.${username} = {
        packages = mainFontPackages ++ fallbackPackages;
        files.".config/fontconfig/fonts.conf" = {
          clobber = true;
          text = fontXmlConfig;
        };
      };
    })

    # Foot configuration
    (lib.mkIf footCfg.enable {
      hjem.users.${username} = {
        packages = with pkgs; [
          foot
        ];
        files.".config/foot/foot.ini" = {
          clobber = true;
          text = lib.mkAfter (lib.generators.toINI {} footConfig);
        };
      };
    })

    # GTK configuration
    (lib.mkIf gtkCfg.enable {
      hjem.users.${username} = {
        packages = with pkgs; [
          gtk3
          gtk4
        ];
        files = {
          ".config/gtk-3.0/settings.ini" = {
            clobber = true;
            text = lib.generators.toINI {} gtk3Settings;
          };
          ".config/gtk-3.0/gtk.css" = {
            clobber = true;
            text = gtkCss;
          };
          ".config/gtk-3.0/bookmarks" = {
            clobber = true;
            text = bookmarksContent;
          };
          ".config/gtk-4.0/settings.ini" = {
            clobber = true;
            text = lib.generators.toINI {} gtk4Settings;
          };
          ".zshenv" = {
            clobber = true;
            text = lib.mkAfter ''
              export XCURSOR_SIZE="${builtins.replaceStrings [".0"] [""] (toString (builtins.floor (24 * scaleFactor)))}"
            '';
          };
        };
      };
    })

    # Hyprland configuration
    (lib.mkIf hyprlandCfg.enable {
      hjem.users.${username} = {
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
                  hyprlandCoreConfig
                  hyprlandIntegrationsConfig
                ];
                allBinds = (hyprlandKeybindingsConfig.bind or []) ++ (hyprlandIntegrationsConfig.bind or []);
                allBindm = (hyprlandKeybindingsConfig.bindm or []) ++ (hyprlandIntegrationsConfig.bindm or []);
                allBindr = (hyprlandKeybindingsConfig.bindr or []) ++ (hyprlandIntegrationsConfig.bindr or []);
                allBinds_hold = (hyprlandKeybindingsConfig.binds or []) ++ (hyprlandIntegrationsConfig.binds or []);
              in
                baseConfig
                // hyprlandKeybindingsConfig
                // hyprlandIntegrationsConfig
                // {
                  bind = allBinds;
                  bindm = allBindm;
                  bindr = allBindr;
                  binds = allBinds_hold;
                };
              pluginsConfig = lib.optionalString hyprlandCfg.hy3.enable (
                generators.pluginsToHyprconf [
                  (
                    if hyprlandCfg.flake.enable
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
    })

    # Mako configuration
    (lib.mkIf makoCfg.enable {
      hjem.users.${username} = {
        packages = with pkgs; [
          mako
        ];
        files.".config/mako/config" = {
          clobber = true;
          text = ''
            actions=true
            anchor=top-right
            background-color=
            border-color=
            border-radius=5
            border-size=1
            default-timeout=5000
            format=<b>%s</b>\n%b
            group-by=
            height=100
            icon-path=
            icons=true
            ignore-timeout=false
            layer=top
            margin=10
            markup=true
            max-icon-size=64
            max-visible=5
            output=
            padding=5
            progress-color=
            sort=-time
            text-color=
            width=300
          '';
        };
        systemd.services.mako = {
          description = "Mako notification daemon";
          documentation = ["man:mako(1)"];
          partOf = ["graphical-session.target"];
          after = ["graphical-session.target"];
          wantedBy = ["graphical-session.target"];
          serviceConfig = {
            Type = "dbus";
            BusName = "org.freedesktop.Notifications";
            ExecStart = "${pkgs.mako}/bin/mako";
            ExecReload = "${pkgs.mako}/bin/makoctl reload";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
      };
    })

    # Niri configuration
    (lib.mkIf niriCfg.enable {
      hjem.users.${username} = {
        packages = [
          pkgs.niri
          pkgs.grim
          pkgs.slurp
          pkgs.wl-clipboard
          pkgs.jq
          pkgs.swaybg
        ];
        files = {
          ".config/niri/config.kdl" = {
            text = ''
              prefer-no-csd

              spawn-at-startup "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
              spawn-at-startup "sh" "-c" "swaybg -i $(find ${config.home.directories.wallpapers.static.path} -type f | shuf -n 1) -m fill"

              input {
                  keyboard {
                      xkb {
                          layout "us"
                      }
                  }
                  touchpad {
                      tap
                      dwt
                      natural-scroll
                      accel-speed 0.0
                  }
                  mouse {
                      accel-speed 0.0
                  }
                  focus-follows-mouse max-scroll-amount="0%"
                  mod-key "Alt"
              }

              output "DP-2" {
                  mode "5120x1440@239.761"
                  position x=0 y=0
              }

              output "HDMI-A-2" {
                  mode "1920x1080@60.000"
                  position x=5120 y=0
              }

              layout {
                  gaps 10
                  center-focused-column "never"
                  default-column-display "tabbed"
                  default-column-width {
                      proportion 0.5
                  }
                  preset-column-widths {
                      proportion 0.33333
                      proportion 0.5
                      proportion 0.66667
                  }

                  border {
                  width 0.5
                  active-color "#ffffff"
                  inactive-color "#333333"
                  }

                  focus-ring {
                      width 0.5
                      active-color "#ffffff"
                      inactive-color "#333333"
                  }

                  tab-indicator {
                      width 4
                      gap 6
                      active-color "#ffffff"
                      inactive-color "#666666"
                      position "left"
                  }
              }

              hotkey-overlay {}

              animations {
                  slowdown 1.0
                  window-open {
                      duration-ms 150
                      curve "ease-out-expo"
                  }
                  window-close {
                      duration-ms 150
                      curve "ease-out-expo"
                  }

              }

              window-rule {
                  match app-id="firefox"
                  default-column-width {
                      proportion 0.75
                  }
              }

              window-rule {
                  match app-id="foot"
                  opacity 1.0
              }

              window-rule {
                  match app-id="launcher"
                  open-floating true
              }

              binds {
                  "Mod+Shift+Slash" { show-hotkey-overlay; }

                  "Mod+T" { spawn "${defaults.terminal}"; }
                  "Super+R" { spawn "foot" "-a" "launcher" "${config.user.configDirectory}/scripts/sway-launcher-desktop.sh"; }

                  "Mod+Q" { close-window; }
                  "Mod+Shift+F" { fullscreen-window; }
                  "Mod+F" { maximize-column; }
                  "Mod+Space" { center-column; }
                  "Super+Space" { toggle-window-floating; }

                  "Mod+Left" { focus-column-left; }
                  "Mod+Right" { focus-column-right; }
                  "Mod+Up" { focus-window-up; }
                  "Mod+Down" { focus-window-down; }
                  "Mod+H" { focus-column-left; }
                  "Mod+L" { focus-column-right; }
                  "Mod+J" { focus-window-down; }
                  "Mod+K" { focus-window-up; }

                  "Mod+Shift+Left" { move-column-left; }
                  "Mod+Shift+Right" { move-column-right; }
                  "Mod+Shift+Up" { move-window-up; }
                  "Mod+Shift+Down" { move-window-down; }
                  "Mod+Shift+H" { move-column-left; }
                  "Mod+Shift+L" { move-column-right; }
                  "Mod+Shift+J" { move-window-down; }
                  "Mod+Shift+K" { move-window-up; }

                  "Mod+Page_Up" { focus-workspace-up; }
                  "Mod+Page_Down" { focus-workspace-down; }
                  "Mod+U" { focus-workspace-up; }
                  "Mod+I" { focus-workspace-down; }
                  "Super+1" { focus-workspace 1; }
                  "Super+2" { focus-workspace 2; }
                  "Super+3" { focus-workspace 3; }
                  "Super+4" { focus-workspace 4; }
                  "Super+5" { focus-workspace 5; }
                  "Super+6" { focus-workspace 6; }
                  "Super+7" { focus-workspace 7; }
                  "Super+8" { focus-workspace 8; }
                  "Super+9" { focus-workspace 9; }

                  "Mod+Ctrl+Page_Up" { move-column-to-workspace-up; }
                  "Mod+Ctrl+Page_Down" { move-column-to-workspace-down; }
                  "Mod+Ctrl+U" { move-column-to-workspace-up; }
                  "Mod+Ctrl+I" { move-column-to-workspace-down; }
                  "Super+Shift+1" { move-column-to-workspace 1; }
                  "Super+Shift+2" { move-column-to-workspace 2; }
                  "Super+Shift+3" { move-column-to-workspace 3; }
                  "Super+Shift+4" { move-column-to-workspace 4; }
                  "Super+Shift+5" { move-column-to-workspace 5; }
                  "Super+Shift+6" { move-column-to-workspace 6; }
                  "Super+Shift+7" { move-column-to-workspace 7; }
                  "Super+Shift+8" { move-column-to-workspace 8; }
                  "Super+Shift+9" { move-column-to-workspace 9; }

                  "Mod+R" { switch-preset-column-width; }
                  "Mod+Shift+R" { switch-preset-window-height; }
                  "Mod+Comma" { consume-window-into-column; }
                  "Mod+Period" { expel-window-from-column; }
                  "Mod+BracketLeft" { consume-or-expel-window-left; }
                  "Mod+BracketRight" { consume-or-expel-window-right; }

                  "Mod+G" { spawn "sh" "-c" "grim -g \"$(slurp -d)\" - | wl-copy -t image/png"; }
                  "Mod+Shift+G" { spawn "sh" "-c" "grim - | wl-copy -t image/png"; }

                  "Mod+Shift+E" { quit; }
                  "Mod+O" { toggle-overview; }

                  "Mod+1" { spawn "${defaults.ide}"; }
                  "Mod+2" { spawn "${defaults.browser}"; }
                  "Mod+3" { spawn "vesktop"; }
                  "Mod+4" { spawn "steam"; }
                  "Mod+5" { spawn "obs"; }

                  "Mod+E" { spawn "${defaults.fileManager}"; }
                  "Mod+Shift+O" { spawn "${defaults.terminal}" "-e" "${defaults.editor}"; }

                  "Mod+Shift+C" { spawn "sh" "-c" "killall swaybg; swaybg -i $(find ${config.home.directories.wallpapers.static.path} -type f | shuf -n 1) -m fill &"; }
              }

              environment {
                  DISPLAY ":0"
              }
            '';
            clobber = true;
          };
        };
      };
    })

    # Qutebrowser configuration
    (lib.mkIf qutebrowserCfg.enable {
      hjem.users.${username} = {
        packages = with pkgs; [
          qutebrowser
        ];
        files.".config/qutebrowser/config.py" = {
          clobber = true;
          text = ''
            # Basic qutebrowser configuration
            config.load_autoconfig(False)

            # Basic settings
            c.zoom.default = 110
            c.fonts.default_family = "monospace"
            c.fonts.default_size = "11pt"

            # Tab settings
            c.tabs.position = "top"
            c.tabs.show = "multiple"
            c.tabs.background = True

            # Downloads
            c.downloads.location.directory = "~/Downloads"

            # Privacy settings
            c.content.cookies.accept = "no-3rdparty"
            c.content.geolocation = "ask"
            c.content.notifications.enabled = "ask"

            # Dark mode
            c.colors.webpage.darkmode.enabled = True
            c.colors.webpage.preferred_color_scheme = "dark"

            # Keybindings
            config.bind('J', 'tab-prev')
            config.bind('K', 'tab-next')
            config.bind('x', 'tab-close')
            config.bind('X', 'undo')
            config.bind('t', 'open -t')
            config.bind('T', 'open -t -r')

            # Search engines
            c.url.searchengines = {
                'DEFAULT': 'https://duckduckgo.com/?q={}',
                'g': 'https://www.google.com/search?q={}',
                'gh': 'https://github.com/search?q={}',
                'nix': 'https://search.nixos.org/packages?query={}',
            }

            # Homepage
            c.url.start_pages = ["https://duckduckgo.com"]
            c.url.default_page = "https://duckduckgo.com"
          '';
        };
      };
    })

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
