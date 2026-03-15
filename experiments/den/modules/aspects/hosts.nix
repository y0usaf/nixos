{
  den,
  inputs,
  lib,
  ...
}: {
  den.aspects.y0usaf-desktop = {
    includes = [
      den.provides.hostname
      den.aspects.linux-base
      den.aspects.linux-workstation
      den.aspects.cpu-amd
      den.aspects.gpu-nvidia
      den.aspects.syncthing-proxy
    ];

    nixos = {pkgs, ...}: {
      imports = [
        ../../../../configs/hosts/y0usaf-desktop/hardware-configuration.nix
      ];

      fonts = {
        packages = [
          inputs.fast-fonts.packages."${pkgs.stdenv.hostPlatform.system}".default
        ];
        fontDir.enable = true;
      };

      nixpkgs.config.cudaSupport = true;
      trustedUsers = ["y0usaf"];
      stateVersion = "24.11";
      timezone = "America/Toronto";
      var-cache = true;

      hardware = {
        bluetooth.enable = true;
        display.outputs =
          (lib.genAttrs ["DP-1" "DP-2" "DP-3" "DP-4"] (_: {mode = "5120x1440@239.76";}))
          // {
            "eDP-1".mode = "1920x1080@300.00";
          };
        nvidia.management = {
          enable = true;
          maxClock = 2450;
          minClock = 1000;
          coreVoltageOffset = -100;
          memoryVoltageOffset = -100;
          fanCurve = [
            {
              temp = 50;
              speed = 0;
            }
            {
              temp = 75;
              speed = 50;
            }
            {
              temp = 90;
              speed = 70;
            }
          ];
        };
      };

      user.gaming = {
        proton = {
          enable = true;
          nativeWayland = false;
          ntsync = true;
        };
        mangohud = {
          enable = true;
          enableSessionWide = true;
          refreshRate = 175;
        };
      };

      services = {
        btrbk-snapshots.enable = true;
        nginx.enable = true;
        syncthing-proxy.virtualHostName = "syncthing-desktop";
      };

      services.openssh.ports = [2222];
      networking.firewall.allowedTCPPorts = [25565 2222];

      boot.windowsDualBoot = {
        enable = true;
        windowsEfiPartuuid = "09d3f11d-33f2-442b-9971-c279ef51860f";
      };
    };
  };

  den.aspects.y0usaf-laptop = {
    includes = [
      den.provides.hostname
      den.aspects.linux-base
      den.aspects.linux-workstation
      den.aspects.cpu-amd
      den.aspects.gpu-amdgpu
      den.aspects.syncthing-proxy
    ];

    nixos = {pkgs, ...}: {
      imports = [
        ../../../../configs/hosts/y0usaf-laptop/hardware-configuration.nix
      ];

      fonts = {
        packages = [
          inputs.fast-fonts.packages."${pkgs.stdenv.hostPlatform.system}".default
        ];
        fontDir.enable = true;
      };

      trustedUsers = ["y0usaf"];
      stateVersion = "24.11";
      timezone = "America/Toronto";
      hardware.bluetooth.enable = true;
      services.syncthing-proxy.virtualHostName = "syncthing-laptop";
    };
  };

  den.aspects.y0usaf-framework = {
    includes = [
      den.provides.hostname
      den.aspects.linux-base
      den.aspects.linux-workstation
      den.aspects.cpu-amd
      den.aspects.gpu-amdgpu
      den.aspects.syncthing-proxy
    ];

    nixos = {pkgs, ...}: {
      imports = [
        ../../../../configs/hosts/y0usaf-framework/hardware-configuration.nix
        ../../../../configs/hosts/y0usaf-framework/impermanence.nix
        ../../../../configs/hosts/y0usaf-framework/home-rollback.nix
      ];

      fonts = {
        packages = [
          inputs.fast-fonts.packages."${pkgs.stdenv.hostPlatform.system}".default
        ];
        fontDir.enable = true;
      };

      trustedUsers = ["y0usaf"];
      stateVersion = "24.11";
      timezone = "America/Toronto";
      environment.systemPackages = [pkgs.brightnessctl];
      hardware.bluetooth.enable = true;
      services.syncthing-proxy.virtualHostName = "syncthing-framework";

      # Preserve the current install-time override until secure boot is modeled.
      boot.loader.limine.secureBoot.enable = lib.mkForce false;
    };
  };

  den.aspects.y0usaf-server = {
    includes = [
      den.provides.hostname
      den.aspects.linux-base
      den.aspects.linux-server
      den.aspects.cpu-intel
      den.aspects.syncthing-proxy
    ];

    nixos = {
      imports = [
        ../../../../configs/hosts/y0usaf-server/hardware-configuration.nix
        ../../../../configs/hosts/y0usaf-server/impermanence.nix
      ];

      trustedUsers = ["y0usaf"];
      stateVersion = "24.11";
      timezone = "America/Toronto";
      var-cache = true;

      hardware = {
        bluetooth.enable = false;
        nvidia = {
          enable = false;
          cuda.enable = false;
        };
        amdgpu.enable = false;
      };

      services = {
        btrbk-snapshots.enable = true;
        mediamtx.enable = true;
        forgejo.enable = true;
        syncthing-proxy.virtualHostName = "syncthing-server";
        n8n = {
          enable = true;
          openFirewall = true;
        };
        openssh.enable = lib.mkForce true;
      };

      networking = {
        nameservers = ["1.1.1.1" "8.8.8.8"];
        useDHCP = false;
        firewall = {
          enable = true;
          allowedTCPPorts = [80 443 2222 3000 22000];
          allowedUDPPorts = [22000 21027];
        };
      };

      services.resolved = {
        enable = true;
        settings.Resolve = {
          FallbackDNS = ["1.1.1.1" "8.8.8.8"];
          DNSSEC = "false";
        };
      };

      boot.loader.limine.secureBoot.enable = lib.mkForce false;
    };
  };

  den.aspects.y0usaf-macbook = {
    includes = [
      den.provides.hostname
      den.aspects.darwin-base
    ];

    darwin = {pkgs, ...}: {
      networking = {
        hostName = "y0usaf-macbook";
        computerName = "y0usaf-macbook";
      };

      system.stateVersion = 5;

      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        trusted-users = ["y0usaf" "@admin"];
      };

      users.users.y0usaf = {
        name = "y0usaf";
        home = "/Users/y0usaf";
      };

      fonts.packages = [
        inputs.fast-fonts.packages."${pkgs.stdenv.hostPlatform.system}".default
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
      };
    };
  };
}
