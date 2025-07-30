{
  config,
  lib,
  ...
}: let
  agsEnabled = config.home.ui.ags.enable or false;
  quickshellEnabled = config.home.ui.quickshell.enable or false;
in {
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
}
