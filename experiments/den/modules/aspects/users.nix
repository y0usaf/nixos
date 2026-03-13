{den, ...}: {
  den.aspects.y0usaf = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "zsh")
      den.aspects.user-profile
    ];
  };

  # Route the legacy profile imports from inventory data instead of
  # repeating them in each host aspect.
  den.aspects.user-profile = {den, user, ...}: {
    includes =
      {
        desktop = [den.aspects.profile-desktop];
        mobile = [den.aspects.profile-mobile];
        server = [den.aspects.profile-server];
        darwin = [den.aspects.profile-darwin];
      }
      .${user.profile}
      or [];
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
