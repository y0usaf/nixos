{den, ...}: {
  den.aspects.y0usaf = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "zsh")
    ];
  };

  # These profile aspects intentionally bridge the existing monolithic files.
  # They are the first extraction seam, not the final den shape.
  den.aspects.profile-desktop = {user, ...}: {
    nixos.imports = [
      ../../../../configs/users/y0usaf.nix
    ];
  };

  den.aspects.profile-mobile = {user, ...}: {
    nixos.imports = [
      ../../../../configs/users/y0usaf-dev.nix
    ];
  };

  den.aspects.profile-server = {user, ...}: {
    nixos.imports = [
      ../../../../configs/users/server.nix
    ];
  };

  den.aspects.profile-darwin = {user, ...}: {
    darwin.imports = [
      ../../../../configs/users/y0usaf-darwin.nix
    ];
  };
}
