{...}: {
  imports = [
    # Boot modules (consolidated from ./boot/default.nix)
    ./boot/kernel.nix
    # loader.nix (14 lines -> INLINED!)
    (_: {
      config = {
        boot.loader = {
          systemd-boot = {
            enable = true;
            configurationLimit = 20;
          };
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
          };
        };
      };
    })

    # Core modules
    ./core

    # Hardware modules
    ./hardware

    # Networking modules (consolidated from ./networking/default.nix)
    # firewall.nix (12 lines -> INLINED!)
    (_: {
      config = {
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [25565];
          allowedUDPPorts = [];
        };
      };
    })
    # networkmanager.nix (3 lines -> INLINED!)
    (_: {config = {networking.networkmanager.enable = true;};})
    # xdg-portal.nix (11 lines -> INLINED!)
    ({pkgs, ...}: {
      config = {
        xdg.portal = {
          enable = true;
          xdgOpenUsePortal = true;
          extraPortals = [pkgs.xdg-desktop-portal-gtk];
        };
      };
    })

    # Programs modules (consolidated from ./programs/default.nix)
    ./programs/hyprland.nix
    # obs.nix (10 lines -> INLINED!)
    ({config, ...}: {
      boot = {
        kernelModules = ["v4l2loopback"];
        extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
        extraModprobeConfig = ''options v4l2loopback exclusive_caps=1'';
      };
      security.polkit.enable = true;
    })

    # Security modules (consolidated from ./security/default.nix)
    # polkit.nix (3 lines -> INLINED!)
    (_: {config = {security.polkit.enable = true;};})
    # rtkit.nix (3 lines -> INLINED!)
    (_: {config = {security.rtkit.enable = true;};})
    # sudo.nix (15 lines -> INLINED!)
    ({config, ...}: {
      config = {
        security.sudo.extraRules = [
          {
            users = [config.hostSystem.username];
            commands = [
              {
                command = "ALL";
                options = ["NOPASSWD"];
              }
            ];
          }
        ];
      };
    })

    # Services modules (consolidated from ./services/default.nix)
    # audio.nix (12 lines -> INLINED!)
    (_: {
      config = {
        services.pipewire = {
          enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
          pulse.enable = true;
        };
      };
    })
    # dbus.nix (11 lines -> INLINED!)
    ({pkgs, ...}: {
      config = {
        services.dbus = {
          enable = true;
          packages = [pkgs.dconf pkgs.gcr];
        };
      };
    })
    ./services/mediamtx.nix
    # scx.nix (9 lines -> INLINED!)
    ({pkgs, ...}: {
      config = {
        services.scx = {
          enable = true;
          scheduler = "scx_lavd";
          package = pkgs.scx.rustscheds;
        };
      };
    })

    # Users modules (consolidated from ./users/default.nix)
    ./users/accounts.nix

    # Virtualization modules (consolidated from ./virtualization/default.nix)
    # android.nix (11 lines -> INLINED!)
    ({
      lib,
      hostSystem,
      ...
    }: {config = {virtualisation.waydroid = lib.mkIf (hostSystem.services.waydroid.enable or false) {enable = true;};};})
    ./virtualization/containers.nix
  ];
}
