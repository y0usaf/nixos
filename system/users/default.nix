{
  helpers,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = helpers.importModules ./.;

  # Enable tmpfiles.d user instance to ensure Hjem file management works
  systemd.tmpfiles.enable = true;
  systemd.user.services.systemd-tmpfiles-setup.enable = true;
  systemd.user.services.systemd-tmpfiles-clean.enable = true;
}
