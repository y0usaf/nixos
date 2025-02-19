{ lib, config, pkgs, ...}:
with lib;
let
  src = builtins.fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/latest/download/zen-x86_64.AppImage";
    sha256 = "16k37ngl4qpqwwj6f9q8jpn20pk8887q8zc0l7qivshmhfib36qq";
  };
in
{
  options = {
    bzv.zen-browser.enable = mkEnableOption "Enable zen browser app image";
  };

  config = mkIf config.bzv.zen-browser.enable {
    environment.systemPackages = [ pkgs.appimage-run ];
    
    xdg.desktopEntries = {
      ZenBrowser = {
        name = "Zen Browser";
        genericName = "Zen";
        exec = "appimage-run ${src}";
        terminal = false;
      };
    };
  };
} 