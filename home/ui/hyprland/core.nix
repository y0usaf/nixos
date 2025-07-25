###############################################################################
# Hyprland Core Settings Module (Maid Version)
# Contains core Hyprland configuration including:
# - General UI settings (gaps, borders, layout)
# - Input settings (keyboard, mouse)
# - Decoration settings (rounding, blur)
# - Animation settings
# - Rendering settings
# - Environment variables
###############################################################################
{
  config,
  lib,
  hostSystem,
  cfg,
  ...
}:
###########################################################################
# Core Hyprland Configuration
###########################################################################
{
  ###########################################################################
  # Theme & Colors (Hyprland Variables)
  ###########################################################################
  "$active_colour" = "ffffffff";
  "$transparent" = "ffffff00";
  "$inactive_colour" = "333333ff";
  ###########################################################################
  # General User Interface Settings
  ###########################################################################
  general = {
    gaps_in = 10;
    gaps_out = 5;
    border_size = 1;
    "col.active_border" = "rgba($active_colour)";
    "col.inactive_border" = "rgba($inactive_colour)";
    layout =
      if cfg.hy3.enable
      then "hy3"
      else if cfg.group.enable
      then "group"
      else "dwindle";
  };

  ###########################################################################
  # Input Settings (keyboard & mouse)
  ###########################################################################
  input = {
    kb_layout = "us";
    follow_mouse = 1;
    sensitivity = -1.0;
    force_no_accel = true;
    mouse_refocus = false;
  };

  ###########################################################################
  # Window Decoration & Effects
  ###########################################################################
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

  ###########################################################################
  # Rendering Settings
  ###########################################################################
  render = {
    cm_enabled = 0;
    explicit_sync = 1;
  };

  ###########################################################################
  # Bezier Curves (Top-level, defined before animations)
  ###########################################################################
  bezier = [
    "in-out,.65,-0.01,0,.95"
    "woa,0,0,0,1"
  ];

  ###########################################################################
  # Animation Settings
  ###########################################################################
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

  ###########################################################################
  # System & Debug Settings
  ###########################################################################
  misc = {
    disable_hyprland_logo = true;
    disable_splash_rendering = true;
  };

  debug.disable_logs = false;

  ###########################################################################
  # Environment Variables
  ###########################################################################
  env =
    # Cursor configuration
    [
      "HYPRCURSOR_THEME,DeepinDarkV20-hypr"
      "HYPRCURSOR_SIZE,${toString config.home.core.appearance.cursorSize}"
      "XCURSOR_THEME,DeepinDarkV20-x11"
      "XCURSOR_SIZE,${toString config.home.core.appearance.cursorSize}"
    ]
    # NVIDIA-specific environment settings
    ++ lib.optionals hostSystem.hardware.nvidia.enable [
      "LIBVA_DRIVER_NAME,nvidia"
      "GBM_BACKEND,nvidia-drm"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
    ];
}
