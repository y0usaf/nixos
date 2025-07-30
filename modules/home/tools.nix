{
  config,
  pkgs,
  lib,
  ...
}: let
  spotdlCfg = config.home.tools.spotdl;
  ytdlpCfg = config.home.tools.yt-dlp;
  nhCfg = config.home.tools.nh;
  jjCfg = config.home.tools.jj;
  gitCfg = config.home.tools.git;
  npinsCfg = config.home.tools.npins-build;
in {
  options = {
    # tools/spotdl.nix (28 lines -> INLINED\!)
    home.tools.spotdl = {
      enable = lib.mkEnableOption "SpotDL music downloading tools";
    };
    # tools/yt-dlp.nix (35 lines -> INLINED\!)
    home.tools.yt-dlp = {
      enable = lib.mkEnableOption "YouTube-DLP media conversion tools";
    };
    # tools/nh.nix (46 lines -> INLINED\!)
    home.tools.nh = {
      enable = lib.mkEnableOption "nh (Nix Helper) shell integration";
      flake = lib.mkOption {
        type = with lib.types; nullOr (either singleLineStr path);
        default = null;
        description = ''
          The path that will be used for the NH_FLAKE environment variable.
          NH_FLAKE is used by nh as the default flake for performing actions,
          like 'nh os switch'. If not set, nh will look for a flake in the current
          directory or prompt for the flake path.
        '';
      };
    };
    # tools/jj.nix (83 lines -> INLINED\!)
    home.tools.jj = {
      enable = lib.mkEnableOption "jujutsu version control system";
      name = lib.mkOption {
        type = lib.types.str;
        description = "Jujutsu username.";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Jujutsu email address.";
      };
      editor = lib.mkOption {
        type = lib.types.str;
        default = "nvim";
        description = "Default editor for jujutsu.";
      };
      enableAliases = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable common jujutsu aliases.";
      };
    };
    # tools/git.nix -> INLINED\!
    home.tools.git = {
      enable = lib.mkEnableOption "git configuration";
      name = lib.mkOption {
        type = lib.types.str;
        description = "Git username.";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Git email address.";
      };
    };
    # tools/npins-build.nix -> INLINED\!
    home.tools.npins-build = {
      enable = lib.mkEnableOption "npins-build helper script";
    };
  };
  
  config = lib.mkMerge [
    (lib.mkIf spotdlCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          ffmpeg
        ];
        files = {
          ".config/zsh/.zshrc" = {
            text = lib.mkAfter ''
              alias spotm4a="uvx spotdl --format m4a --output '{title}'"
              alias spotmp3="uvx spotdl --format mp3 --output '{title}'"
            '';
            clobber = true;
          };
        };
      };
    })
    (lib.mkIf ytdlpCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          yt-dlp-light
          ffmpeg
        ];
        files = {
          ".config/zsh/.zshrc" = {
            text = lib.mkAfter ''
              alias ytm4a="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -x --audio-format m4a --embed-metadata --add-metadata -o '%(title)s.%(ext)s'"
              alias ytmp3="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -x --audio-format mp3 --embed-metadata --add-metadata -o '%(title)s.%(ext)s'"
              alias ytmp4="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -f 'bv*[height<=720]+ba/b[height<=720]' --recode-video mp4 --embed-metadata --add-metadata --postprocessor-args 'ffmpeg:-c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k -vf scale=-2:720' -o '%(title)s.%(ext)s'"
              alias ytmp4s="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -f 'bv*[height<=480]+ba/b[height<=480]' --recode-video mp4 --embed-metadata --add-metadata --postprocessor-args 'ffmpeg:-c:v libx264 -crf 26 -preset faster -c:a aac -b:a 96k -vf scale=-2:480' -o '%(title)s.%(ext)s'"
              alias ytwebm="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -f 'bv*[height<=720]+ba/b[height<=720]' --recode-video webm --embed-metadata --add-metadata --postprocessor-args 'ffmpeg:-c:v libvpx-vp9 -crf 30 -b:v 0 -c:a libopus -vf scale=-2:720' -o '%(title)s.%(ext)s'"
              alias ytdiscord="yt-dlp --extractor-args 'youtube:player_client=android' --no-check-certificate -f 'bv*[height<=720]+ba/b[height<=720]' --recode-video mp4 --embed-metadata --add-metadata --postprocessor-args 'ffmpeg:-c:v libx264 -crf 28 -preset faster -c:a aac -b:a 96k -vf scale=-2:min(720,ih) -fs 7.8M' -o '%(title)s_discord.%(ext)s'"
            '';
            clobber = true;
          };
        };
      };
    })
    (lib.mkIf nhCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          nh
        ];
        files = {
          ".config/zsh/.zshrc" = {
            text = lib.mkAfter ''
              export NH_FLAKE="${config.user.nixosConfigDirectory}"
              nhs() {
                clear
                local update=""
                local dry=""
                local OPTIND
                while getopts "du" opt; do
                  case $opt in
                    d) dry="--dry" ;;
                    u) update="--update" ;;
                    *) echo "Invalid option: -$OPTARG" >&2 ;;
                  esac
                done
                shift $((OPTIND-1))
                nh os switch $update $dry "$@"
              }
              alias nhd="nhs -d"
              alias nhu="nhs -u"
              alias nhud="nhs -ud"
              alias nhc="nh clean all"
            '';
            clobber = true;
          };
        };
      };
    })
    (lib.mkIf jjCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          jujutsu
        ];
        files =
          {
            ".config/jj/config.toml" = {
              text = ''
                [user]
                name = "${jjCfg.name}"
                email = "${jjCfg.email}"
                [ui]
                default-command = "status"
                editor = "${jjCfg.editor}"
                diff-editor = "${jjCfg.editor}"
                [git]
                auto-local-branch = true
                push-branch-prefix = ""
                [revset-aliases]
                "mine" = "author(${jjCfg.email})"
                "recent" = "heads(::@ & recent(5))"
                ${lib.optionalString jjCfg.enableAliases ''
                  [aliases]
                  l = ["log", "-r", "recent"]
                  ll = ["log", "-r", "::@"]
                  s = ["status"]
                  d = ["diff"]
                  c = ["commit"]
                  ca = ["commit", "--amend"]
                  co = ["checkout"]
                  n = ["new"]
                  e = ["edit"]
                  b = ["branch"]
                  rb = ["rebase"]
                  sp = ["split"]
                  sq = ["squash"]
                ''}
              '';
              clobber = true;
            };
          }
          // lib.optionalAttrs jjCfg.enableAliases {
            ".config/zsh/.zshrc" = {
              text = ''
                alias jl='jj log -r recent'
                alias jll='jj log -r ::@'
                alias js='jj status'
                alias jd='jj diff'
                alias jc='jj commit'
                alias jca='jj commit --amend'
                alias jco='jj checkout'
                alias jn='jj new'
                alias je='jj edit'
                alias jb='jj branch'
                alias jrb='jj rebase'
                alias jsp='jj split'
                alias jsq='jj squash'
              '';
              clobber = true;
            };
          };
      };
    })
    (lib.mkIf gitCfg.enable {
      hjem.users.${config.user.name}.files = {
        ".config/git/config" = {
          text = ''
            [user]
                name = ${gitCfg.name}
                email = ${gitCfg.email}
            [core]
                editor = nvim
                autocrlf = false
            [init]
                defaultBranch = main
            [push]
                default = simple
            [pull]
                rebase = false
            [diff]
                tool = nvimdiff
                colorMoved = default
            [merge]
                tool = nvimdiff
            [difftool "nvimdiff"]
                cmd = nvim -d "$LOCAL" "$REMOTE"
            [mergetool "nvimdiff"]
                cmd = nvim -d "$LOCAL" "$REMOTE" "$MERGED" -c '$wincmd w' -c 'wincmd J'
            [alias]
                st = status
                co = checkout
                br = branch
                ci = commit
                ca = commit --amend
                unstage = reset HEAD --
                last = log -1 HEAD
                visual = \!gitk
                amend = commit --amend --no-edit
                graph = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
                tree = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all
                oops = commit --amend --no-edit
                wip = commit -am "WIP"
                unwip = reset HEAD~1
            [credential]
                helper = store
            [color]
                ui = auto
            [color "diff"]
                meta = yellow bold
                commit = green bold
                frag = magenta bold
                old = red bold
                new = green bold
                whitespace = red reverse
            [color "diff-highlight"]
                oldNormal = red bold
                oldHighlight = red bold 52
                newNormal = green bold
                newHighlight = green bold 22
          '';
          clobber = true;
        };
      };
    })
    (lib.mkIf npinsCfg.enable {
      hjem.users.${config.user.name}.files = {
        ".config/zsh/.zshrc" = {
          text = lib.mkAfter ''
            npins-build() {
                nix-build -E 'let sources = import ./npins; in (import sources.nixpkgs {}).callPackage ./. { inherit sources; }' "$@"
            }
          '';
          clobber = true;
        };
      };
    })
  ];
}
