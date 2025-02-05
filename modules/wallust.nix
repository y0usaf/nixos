#===============================================================================
#                    🎨 Wallust Color Generation 🎨
#===============================================================================
# 🖼️ Wallpaper-based color scheme generation
# 🎯 System-wide theme integration
# 🔄 Auto-generation on wallpaper change
#===============================================================================
{
  config,
  pkgs,
  lib,
  profile,
  inputs,
  ...
}: {
  config = lib.mkIf (builtins.elem "wallust" profile.features) {
    # Install wallust package and custom hyprpaper
    home.packages = [
      pkgs.wallust
      inputs.hyprpaper.packages.${pkgs.system}.default
    ];
  };
}
