{nixpkgs, ...} @ inputs: let
  system = "x86_64-linux";
  inherit (nixpkgs) lib;

  mkHost = {
    domains,
    hostDir,
    profileDir,
  }:
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        flakeInputs = inputs;
      };
      modules =
        (import ./recursivelyImport.nix {
          inherit (lib) hasSuffix;
          inherit (lib.filesystem) listFilesRecursive;
        }) (
          lib.concatMap (domain:
            {
              core = [./modules/core];
              desktop = [./modules/desktop];
              shell = [./modules/shell];
              tools = [./modules/tools];
              user-services = [./modules/user-services];
              dev = [./modules/dev];
              gaming = [./modules/gaming];
            }."${domain}")
          domains
          ++ [
            profileDir
            hostDir
          ]
        );
    };
in {
  nixosConfigurations = {
    y0usaf-desktop = mkHost {
      hostDir = ./hosts/y0usaf-desktop;
      profileDir = ./modules/profiles/y0usaf;
      domains = ["core" "desktop" "shell" "tools" "user-services" "dev" "gaming"];
    };

    y0usaf-laptop = mkHost {
      hostDir = ./hosts/y0usaf-laptop;
      profileDir = ./modules/profiles/y0usaf;
      domains = ["core" "desktop" "shell" "tools" "user-services" "dev" "gaming"];
    };

    y0usaf-framework = mkHost {
      hostDir = ./hosts/y0usaf-framework;
      profileDir = ./modules/profiles/y0usaf-dev;
      domains = ["core" "desktop" "shell" "tools" "user-services" "dev" "gaming"];
    };

    y0usaf-server = mkHost {
      hostDir = ./hosts/y0usaf-server;
      profileDir = ./modules/profiles/server;
      domains = ["core" "shell" "tools" "user-services" "dev"];
    };
  };

  nixOnDroidConfigurations = {
    default = inputs."nix-on-droid".lib.nixOnDroidConfiguration {
      pkgs = import nixpkgs {
        system = "aarch64-linux";
      };
      modules = [
        ./hosts/android-phone/nix-on-droid.nix
      ];
    };
  };

  formatter."${system}" = nixpkgs.legacyPackages."${system}".alejandra;
}
