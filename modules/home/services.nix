{
  config,
  pkgs,
  lib,
  ...
}: let
  polkitAgentCfg = config.home.services.polkitAgent;
  polkitGnomeCfg = config.home.services.polkitGnome;
  formatNixCfg = config.home.services.formatNix;
  sshCfg = config.home.services.ssh;
  syncthingCfg = config.home.services.syncthing;
  nixosGitSyncCfg = config.home.services.nixosGitSync;
  
  formatScript = pkgs.writeShellScript "format-nix-watcher" ''
    set -e
    WATCH_DIR="${formatNixCfg.watchDirectory}"
    cd "$WATCH_DIR"

    echo "Starting Nix file watcher on $WATCH_DIR..."

    ${pkgs.inotify-tools}/bin/inotifywait -m -r -e modify,create,move \
      --include='.*\.nix$' \
      "$WATCH_DIR" | while read path action file; do

      if [[ "$file" =~ \.nix$ ]]; then
        echo "Detected $action on $file, formatting..."
        ${pkgs.alejandra}/bin/alejandra "$path$file"
        echo "✅ Formatted $file"
      fi
    done
  '';
in {
  options = {
    # services/polkit-agent.nix (27 lines -> INLINED\!)
    home.services.polkitAgent = {
      enable = lib.mkEnableOption "polkit authentication agent";
    };
    # services/polkit-gnome.nix (27 lines -> INLINED\!)
    home.services.polkitGnome = {
      enable = lib.mkEnableOption "polkit GNOME authentication agent";
    };
    # services/format-nix.nix (47 lines -> INLINED\!)
    home.services.formatNix = {
      enable = lib.mkEnableOption "automatic Nix file formatting with alejandra";
      watchDirectory = lib.mkOption {
        type = lib.types.str;
        default = config.user.nixosConfigDirectory;
        description = "Directory to watch for Nix file changes";
      };
    };
    # services/ssh.nix (49 lines -> INLINED\!)
    home.services.ssh = {
      enable = lib.mkEnableOption "SSH configuration module";
    };
    # services/syncthing.nix (58 lines -> INLINED\!)
    home.services.syncthing = {
      enable = lib.mkEnableOption "Syncthing service";
    };
    # services/nixos-git-sync.nix (56 lines -> INLINED\!)
    home.services.nixosGitSync = {
      enable = lib.mkEnableOption "NixOS configuration git sync service";
      repoPath = lib.mkOption {
        type = lib.types.str;
        default = config.user.nixosConfigDirectory;
        description = "Path to the NixOS configuration repository";
      };
      remoteBranch = lib.mkOption {
        type = lib.types.str;
        default = "main";
        description = "Remote branch to push to";
      };
    };
  };
  
  config = lib.mkMerge [
    (lib.mkIf polkitAgentCfg.enable {
      hjem.users.${config.user.name}.packages = [pkgs.polkit_gnome];
      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    })
    (lib.mkIf polkitGnomeCfg.enable {
      hjem.users.${config.user.name}.packages = [pkgs.polkit_gnome];
      systemd.user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = ["graphical-session.target"];
        after = ["graphical-session.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    })
    (lib.mkIf formatNixCfg.enable {
      hjem.users.${config.user.name}.packages = [pkgs.alejandra pkgs.inotify-tools];
      systemd.user.services.format-nix-watcher = {
        description = "Watch and format Nix files on change";
        after = ["graphical-session.target"];
        wantedBy = ["default.target"];
        serviceConfig = {
          Type = "simple";
          ExecStart = formatScript;
          Restart = "always";
          RestartSec = "5";
        };
      };
    })
    (lib.mkIf sshCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          openssh
        ];
        files = {
          ".ssh/config" = {
            clobber = true;
            text = ''
              ForwardAgent yes
              AddKeysToAgent yes
              ServerAliveInterval 60
              ServerAliveCountMax 5
              ControlMaster auto
              ControlPath %d/.ssh/master-%r@%h:%p
              ControlPersist 10m
              SetEnv TERM=xterm-256color
              Host github.com
                  HostName github.com
                  User git
                  IdentityFile ${config.user.tokensDirectory}/id_rsa_${config.user.name}
            '';
          };
          "{{xdg_config_home}}/zsh/.zshenv" = {
            clobber = true;
            text = lib.mkAfter ''
              export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
            '';
          };
        };
      };
      systemd.user.services.ssh-agent = {
        description = "SSH key agent";
        wantedBy = ["default.target"];
        serviceConfig = {
          Type = "forking";
          Environment = "SSH_AUTH_SOCK=%t/ssh-agent";
          ExecStart = "${pkgs.openssh}/bin/ssh-agent -a $SSH_AUTH_SOCK";
          ExecStartPost = "${pkgs.coreutils}/bin/systemctl --user set-environment SSH_AUTH_SOCK=$SSH_AUTH_SOCK";
        };
      };
    })
    (lib.mkIf syncthingCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          syncthing
        ];
        files.".config/syncthing/.keep" = {
          clobber = true;
          text = '''';
        };
      };
      systemd.user.services.syncthing = {
        enable = true;
        wantedBy = ["default.target"];
        after = ["network.target"];
        serviceConfig = {
          ExecStart = "${pkgs.syncthing}/bin/syncthing serve --no-browser --no-restart --logflags=0";
          Restart = "on-failure";
          RestartSec = "5s";
          WorkingDirectory = config.user.homeDirectory;
          StateDirectory = "syncthing";
          StateDirectoryMode = "0700";
          ProtectSystem = "strict";
          ProtectHome = "read-only";
          ReadWritePaths = [config.user.homeDirectory];
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          LockPersonality = true;
          RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
          SystemCallFilter = "@system-service";
          SystemCallErrorNumber = "EPERM";
        };
      };
    })
    (lib.mkIf nixosGitSyncCfg.enable {
      systemd.user.services."nixos-git-sync" = {
        description = "Sync NixOS configuration changes after successful build";
        script = ''
                        set -x
                        sleep 2
                        REPO_PATH="${nixosGitSyncCfg.repoPath}"
                        if [ \! -d "$REPO_PATH" ]; then
                          echo "Repository directory does not exist: $REPO_PATH"
                          exit 1
                        fi
                        cd "$REPO_PATH"
                        if \! git diff --quiet HEAD || [ -n "$(git ls-files --others --exclude-standard)" ]; then
                          git add .
                          FORMATTED_DATE=$(date '+%d/%m/%y@%H:%M:%S')
                          CHANGED_FILES=$(git diff --cached --name-status | sed 's/^\(.*\)\t\(.*\)$/- [\1] \2/')
                          COMMIT_MSG="🤖 Auto Update: $FORMATTED_DATE
              Files changed:
              $CHANGED_FILES"
                          git commit -m "$COMMIT_MSG"
                          git push origin ${nixosGitSyncCfg.remoteBranch} --force
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
