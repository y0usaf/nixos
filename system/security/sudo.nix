###############################################################################
# Sudo Configuration Module
# System administrator privileges:
# - User-specific sudo rules
# - Password-less sudo for specific users
# - Fine-grained command permissions
###############################################################################
{config, ...}: {
  config = {
    ###########################################################################
    # Sudo Configuration
    # Configure sudo permissions for users
    ###########################################################################
    security.sudo.extraRules = [
      {
        users = [config.hostSystem.username]; # The user defined in the host config
        commands = [
          {
            command = "ALL"; # Allow all commands
            options = ["NOPASSWD"]; # No password prompt for these commands
          }
        ];
      }
    ];
  };
}
