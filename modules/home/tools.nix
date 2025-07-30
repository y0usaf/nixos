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
      nixos-git-sync = {
        enable = lib.mkEnableOption "NixOS configuration git sync service";
        nixosRepoUrl = lib.mkOption {
          type = lib.types.str;
          description = "Git repository URL for NixOS configuration";
        };
        remoteBranch = lib.mkOption {
          type = lib.types.str;
          default = "main";
          description = "Remote branch to push to";
        };
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
        # zsh aliases moved to shell.nix to prevent conflicts
      };
    })
    (lib.mkIf ytdlpCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          yt-dlp-light
          ffmpeg
        ];
        # zsh aliases moved to shell.nix to prevent conflicts
      };
    })
    (lib.mkIf nhCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          nh
        ];
        # zsh aliases moved to shell.nix to prevent conflicts
      };
    })
    (lib.mkIf jjCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          jujutsu
        ];
        files = {
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
        };
        # zsh aliases moved to shell.nix to prevent conflicts
      };
    })
    (lib.mkIf gitCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [git-lfs];
        files = {
          ".local/share/bin/nixos-git-sync" = {
            executable = true;
            text = ''
                      #!/usr/bin/env bash
                      set -x
                      sleep 2
                      REPO_PATH="${config.user.nixosConfigDirectory}"
                      if [ ! -d "$REPO_PATH" ]; then
                        echo "Repository directory does not exist: $REPO_PATH"
                        exit 1
                      fi
                      cd "$REPO_PATH"
                      if ! git diff --quiet HEAD || [ -n "$(git ls-files --others --exclude-standard)" ]; then
                        git add .
                        FORMATTED_DATE=$(date '+%d/%m/%y@%H:%M:%S')
                        CHANGED_FILES=$(git diff --cached --name-status | sed 's/^\(.*\)\t\(.*\)$/- [\1] \2/')
                        COMMIT_MSG="🤖 Auto Update: $FORMATTED_DATE
              Files changed:
              $CHANGED_FILES"
                        git commit -m "$COMMIT_MSG"
                        git push origin ${gitCfg.nixos-git-sync.remoteBranch} --force
                      else
                        echo "No changes to commit"
                      fi
            '';
            clobber = true;
          };
          ".local/share/bin/setup-nixos-repo" = {
            executable = true;
            text = ''
              #!/usr/bin/env bash
              set -e
              REPO_DIR="${config.user.nixosConfigDirectory}"
              REPO_URL="${gitCfg.nixos-git-sync.nixosRepoUrl}"

              if [ ! -d "$REPO_DIR" ]; then
                echo "Setting up NixOS repository at $REPO_DIR"
                git clone "$REPO_URL" "$REPO_DIR"
                cd "$REPO_DIR"
              else
                echo "Repository already exists at $REPO_DIR"
                cd "$REPO_DIR"
                git remote set-url origin "$REPO_URL"
                git pull origin ${gitCfg.nixos-git-sync.remoteBranch} || true
              fi

              echo "Repository setup complete"
            '';
            clobber = true;
          };
          "gitconfig" = {
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
      };
    })
    (lib.mkIf npinsCfg.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [npins];
      # npins-build function moved to shell.nix to prevent conflicts
    })
    (lib.mkIf gitCfg.nixos-git-sync.enable {
      systemd.user.services."nixos-git-sync" = {
        description = "Sync NixOS configuration changes after successful build";
        script = ''
                    set -x
                    sleep 2
                    REPO_PATH="${config.user.nixosConfigDirectory}"
                    if [ ! -d "$REPO_PATH" ]; then
                      echo "Repository directory does not exist: $REPO_PATH"
                      exit 1
                    fi
                    cd "$REPO_PATH"
                    if ! git diff --quiet HEAD || [ -n "$(git ls-files --others --exclude-standard)" ]; then
                      git add .
                      FORMATTED_DATE=$(date '+%d/%m/%y@%H:%M:%S')
                      CHANGED_FILES=$(git diff --cached --name-status | sed 's/^\(.*\)\t\(.*\)$/- [\1] \2/')
                      COMMIT_MSG="🤖 Auto Update: $FORMATTED_DATE
          Files changed:
          $CHANGED_FILES"
                      git commit -m "$COMMIT_MSG"
                      git push origin ${gitCfg.nixos-git-sync.remoteBranch} --force
                    else
                      echo "No changes to commit"
                    fi
        '';
        serviceConfig.Type = "oneshot";
        path = with pkgs; [git coreutils openssh];
        environment = {
          SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
        };
        wantedBy = ["default.target"];
      };
    })
  ];
}
