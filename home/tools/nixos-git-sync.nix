###############################################################################
# NixOS Configuration Git Sync
# Automatic syncing of NixOS configuration changes
###############################################################################
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.cfg.tools.git.nixos-git-sync;
  gitCfg = config.cfg.tools.git;
in {
  # No options here - they're nested under the git module

  ###########################################################################
  # Module Configuration
  ###########################################################################
  config = lib.mkIf (gitCfg.enable && cfg.enable) {
    # The service configuration
    systemd.user.services.nixos-git-sync = {
      Unit = {
        Description = "Sync NixOS configuration changes after successful build";
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = false;
        Environment = [
          "PATH=${lib.makeBinPath [pkgs.git pkgs.coreutils pkgs.openssh]}"
          "SSH_AUTH_SOCK=%t/ssh-agent"
        ];

        ExecStart = pkgs.writeShellScript "nixos-git-sync" ''
          # Enable debug output for logging
          set -x

          # Sleep briefly to ensure all file writes are complete
          sleep 2

          # Get repository path
          REPO_PATH="${cfg.repoPath}"

          # Check if repository exists
          if [ ! -d "$REPO_PATH" ]; then
            echo "Repository directory does not exist: $REPO_PATH"
            exit 1
          fi

          # Switch to the NixOS configuration repository directory
          cd "$REPO_PATH"

          # Assess if there are any changes (tracked or untracked)
          if ! git diff --quiet HEAD || [ -n "$(git ls-files --others --exclude-standard)" ]; then
            # Stage all changes
            git add .

            # Format date for commit message
            FORMATTED_DATE=$(date '+%d/%m/%y@%H:%M:%S')

            # Replace date placeholder in commit message format
            COMMIT_MSG="🤖 Auto Update: $FORMATTED_DATE"

            # Commit with the formatted message
            git commit -m "$COMMIT_MSG"

            # Push to the configured remote branch
            git push origin ${cfg.remoteBranch} --force
          else
            echo "No changes to commit"
          fi
        '';
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
