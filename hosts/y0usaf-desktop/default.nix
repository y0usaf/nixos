# UNIFIED HOST CONFIGURATION for y0usaf-desktop
{pkgs, ...}: let
  username = "y0usaf";
  homeDir = "/home/${username}";
in {
  cfg = {
    # SYSTEM CONFIGURATION (includes hardware)
    system = {
      inherit username;
      homeDirectory = homeDir;
      hostname = "y0usaf-desktop";
      stateVersion = "24.11";
      timezone = "America/Toronto";
      config = "default";

      # Move imports inside system configuration to avoid HM exposure
      imports = [
        ./hardware-configuration.nix
        ./disko.nix
      ];

      hardware = {
        bluetooth = {
          enable = true;
        };
        nvidia = {
          enable = true;
          cuda.enable = true;
        };
        amdgpu.enable = false;
      };
    };

    # HOME-MANAGER CONFIGURATION
    home = {
      ui = {
        hyprland = {
          enable = true;
          flake.enable = true;
          hy3.enable = true;
        };
        wayland.enable = true;
        ags.enable = true;
        cursor.enable = true;
        kitty.enable = false;
        foot.enable = true;
        gtk = {
          enable = true;
          scale = 1.5;
        };
        wallust.enable = false;
        mako.enable = true;
      };

      # Appearance
      appearance = {
        dpi = 109;
        baseFontSize = 12;
        cursorSize = 36;
        fonts = {
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
        };
      };

      # Default Applications
      defaults = {
        browser = "firefox";
        editor = "nvim";
        ide = "cursor";
        terminal = "foot";
        fileManager = "pcmanfm";
        launcher = "foot -a 'launcher' ~/.config/scripts/sway-launcher-desktop.sh";
        discord = "discord-canary";
        archiveManager = "7z";
        imageViewer = "imv";
        mediaPlayer = "mpv";
      };

      # Applications
      programs = {
        bambu.enable = true;
        discord.enable = true;
        vesktop.enable = true;
        creative.enable = true;
        chatgpt.enable = true;
        android.enable = false;
        firefox.enable = true;
        imv.enable = true;
        pcmanfm.enable = true;
        mpv.enable = true;
        obsidian.enable = true;
        media.enable = true;
        music.enable = true;
        obs.enable = true;
        qbittorrent.enable = true;
        streamlink.enable = false;
        sway-launcher-desktop.enable = true;
        syncthing.enable = true;
        webapps.enable = true;
        zen-browser.enable = false;
        bluetooth.enable = true;
      };

      # Gaming
      gaming = {
        enable = true;
        controllers.enable = true;
        emulation = {
          wii-u.enable = true;
          gcn-wii.enable = true;
        };
        balatro = {
          enable = true;
          enableLovelyInjector = true;
          enabledMods = ["steamodded" "talisman" "morespeeds" "cardsleeves" "multiplayer" "jokerdisplay" "pokermon" "aura" "handybalatro" "stickersalwaysshown"];
        };
      };

      tools = {
        git = {
          enable = true;
          name = "y0usaf";
          email = "OA99@Outlook.com";
          nixos-git-sync = {
            enable = true;
            nixosRepoUrl = "git@github.com:y0usaf/nixos.git";
            remoteBranch = "hjem";
          };
        };
        spotdl.enable = true;
        yt-dlp.enable = true;
        file-roller.enable = true;
        "7z".enable = true;
      };

      # Development
      dev = {
        docker.enable = true;
        fhs.enable = true;
        claude-code.enable = true;
        mcp.enable = true;
        npm.enable = true;
        nvim.enable = true;
        python.enable = true;
        cursor-ide.enable = true;
        latex.enable = true;
      };

      # User Preferences
      user = {
        bookmarks = [
          "file:///home/${username}/Downloads Downloads"
          "file:///home/${username}/Music Music"
          "file:///home/${username}/DCIM DCIM"
          "file:///home/${username}/Pictures Pictures"
          "file:///home/${username}/nixos NixOS"
          "file:///home/${username}/Dev Dev"
          "file:///home/${username}/.local/share/Steam Steam"
        ];
        packages = with pkgs; [
          realesrgan-ncnn-vulkan
          fontforge
        ];
      };

      # Directories
      directories = {
        flake.path = "${homeDir}/nixos";
        music.path = "${homeDir}/Music";
        dcim.path = "${homeDir}/DCIM";
        steam = {
          path = "${homeDir}/.local/share/Steam";
          create = false;
        };
        wallpapers = {
          static.path = "${homeDir}/DCIM/Wallpapers/32_9";
          video.path = "${homeDir}/DCIM/Wallpapers_Video";
        };
      };
    };

    # Hjem Configuration
    hjem = {
      files = {
        # Example file to verify Hjem is working
        ".config/hjem-test.txt".text = ''
          Hjem is now integrated into your NixOS configuration!
          This file confirms that Hjem is properly set up.
        '';

        # Shell configuration
        ".config/shell/aliases.sh".text = ''
          # Shell aliases
          alias ls='ls --color=auto'
          alias ll='ls -la'
          alias grep='grep --color=auto'
          alias nixswitch='cd ~/nixos && nh os switch'
          alias nixedit='cd ~/nixos && $EDITOR'
        '';

        # Git configuration
        ".gitconfig".text = ''
          [user]
            name = ${username}
            email = OA99@Outlook.com

          [init]
            defaultBranch = main

          [pull]
            rebase = false

          [push]
            autoSetupRemote = true
        '';

        # Kitty terminal configuration
        ".config/kitty/kitty.conf".text = ''
          # Kitty configuration
          font_family      Fast_Mono
          bold_font        auto
          italic_font      auto
          bold_italic_font auto
          font_size 12.0

          # Theme
          background_opacity 0.95
          background #282c34
          foreground #abb2bf
          cursor #528bff

          # Colors
          color0 #282c34
          color1 #e06c75
          color2 #98c379
          color3 #e5c07b
          color4 #61afef
          color5 #c678dd
          color6 #56b6c2
          color7 #abb2bf
        '';
      };
    };

    # SHARED CONFIGURATION (both system and home)
    core = {
      # Local home-specific settings
      xdg = {
        enable = true;
      };
      systemd = {
        enable = true;
        autoFormatNix = {
          enable = true;
          directory = "~/nixos";
        };
      };
      zsh = {
        enable = true;
        cat-fetch = true;
        history-memory = 10000;
        history-storage = 10000;
        zellij = {
          enable = true;
        };
      };
      env = {
        enable = true;
        tokenDir = "${homeDir}/Tokens";
      };
    };
  };

  users.users.${username}.extraGroups = ["docker"];
}
