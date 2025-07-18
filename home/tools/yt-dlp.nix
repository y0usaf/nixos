###############################################################################
# YouTube-DLP Module
# Tools for downloading and converting media from YouTube and other sites
###############################################################################
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.home.tools.yt-dlp;
in {
  ###########################################################################
  # Module Options
  ###########################################################################
  options.home.tools.yt-dlp = {
    enable = lib.mkEnableOption "YouTube-DLP media conversion tools";
  };

  ###########################################################################
  # Module Configuration
  ###########################################################################
  config = lib.mkIf cfg.enable {
    ###########################################################################
    # Packages
    ###########################################################################
    users.users.y0usaf.maid.packages = with pkgs; [
      yt-dlp-light # Lightweight tool for downloading videos
      ffmpeg # Required for media conversion
    ];

    ###########################################################################
    # Shell Aliases (added to .zshrc)
    ###########################################################################
    users.users.y0usaf.maid.file.home."{{xdg_config_home}}/zsh/.zshrc".text = lib.mkAfter ''

      # ----------------------------
      # YouTube-DLP Aliases
      # ----------------------------
      # YouTube-DLP aliases for various formats
      alias ytm4a="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -x --audio-format m4a --embed-metadata --add-metadata -o '%(title)s.%(ext)s'"
      alias ytmp3="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -x --audio-format mp3 --embed-metadata --add-metadata -o '%(title)s.%(ext)s'"
      # Discord-compatible MP4 (H.264/AAC, smaller size)
      alias ytmp4="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -f 'bv*[height<=720]+ba/b[height<=720]' --recode-video mp4 --embed-metadata --add-metadata --postprocessor-args 'ffmpeg:-c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k -vf scale=-2:720' -o '%(title)s.%(ext)s'"
      # Discord-compatible smaller MP4 for larger videos
      alias ytmp4s="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -f 'bv*[height<=480]+ba/b[height<=480]' --recode-video mp4 --embed-metadata --add-metadata --postprocessor-args 'ffmpeg:-c:v libx264 -crf 26 -preset faster -c:a aac -b:a 96k -vf scale=-2:480' -o '%(title)s.%(ext)s'"
      alias ytwebm="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -f 'bv*[height<=720]+ba/b[height<=720]' --recode-video webm --embed-metadata --add-metadata --postprocessor-args 'ffmpeg:-c:v libvpx-vp9 -crf 30 -b:v 0 -c:a libopus -vf scale=-2:720' -o '%(title)s.%(ext)s'"
      # Discord-friendly - 8MB limit version
      alias ytdiscord="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -f 'bv*[height<=720]+ba/b[height<=720]' --recode-video mp4 --embed-metadata --add-metadata --postprocessor-args 'ffmpeg:-c:v libx264 -crf 28 -preset faster -c:a aac -b:a 96k -vf scale=-2:min(720\\,ih) -fs 7.8M' -o '%(title)s_discord.%(ext)s'"
    '';
  };
}
