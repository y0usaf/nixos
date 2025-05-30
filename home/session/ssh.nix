###############################################################################
# SSH Configuration Module
# Configures SSH client and agent for secure remote connections
# - SSH client configuration with proper permissions
# - SSH key management with auto-adding to agent
# - GitHub connection setup
# - SSH agent service
###############################################################################
{
  config,
  lib,
  ...
}: let
  cfg = config.cfg.core.ssh;
in {
  ###########################################################################
  # Module Options
  ###########################################################################
  options.cfg.core.ssh = {
    enable = lib.mkEnableOption "SSH configuration module";
  };

  ###########################################################################
  # Module Configuration
  ###########################################################################
  config = lib.mkIf cfg.enable {
    ###########################################################################
    # SSH Client Configuration
    ###########################################################################
    programs.ssh = {
      enable = true;
      forwardAgent = true; # Enable SSH agent forwarding
      addKeysToAgent = "yes"; # Automatically add keys to agent when used
      serverAliveInterval = 60; # Send keepalive packets every 60 seconds
      serverAliveCountMax = 5; # Allow 5 missed keepalives before disconnecting
      controlMaster = "auto"; # Enable connection multiplexing
      controlPersist = "10m"; # Keep connections alive for 10 minutes

      extraConfig = ''
        SetEnv TERM=xterm-256color
      '';

      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/Tokens/id_rsa_y0usaf";
        };
      };
    };

    ###########################################################################
    # SSH Agent Service
    ###########################################################################
    services.ssh-agent.enable = true;

    ###########################################################################
    # XDG integration
    ###########################################################################
    xdg.enable = true;
  };
}
