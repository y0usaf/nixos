###############################################################################
# Vesktop Module (Maid)
# Alternate Discord client with Vencord built-in
###############################################################################
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.home.programs.vesktop;
in {
  ###########################################################################
  # Module Options
  ###########################################################################
  options.home.programs.vesktop = {
    enable = lib.mkEnableOption "Vesktop (Discord client) module";
  };

  ###########################################################################
  # Module Configuration
  ###########################################################################
  config = lib.mkIf cfg.enable {
    ###########################################################################
    # Maid Configuration
    ###########################################################################
    users.users.y0usaf.maid.packages = [pkgs.vesktop];
  };
}
