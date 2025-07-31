{...}: {
  imports = [
    # Boot modules (consolidated from ./boot/default.nix)
    # kernel.nix (28 lines -> INLINED!)
    ({
      lib,
      pkgs,
      hostSystem,
      ...
    }: {
      config = {
        boot = {
          kernelPackages = pkgs.linuxPackages_latest; # TODO: Re-enable linuxPackages_cachyos when chaotic is fixed
          kernelModules =
            [
              "kvm-amd"
              "k10temp"
              "nct6775"
              "ashmem_linux"
              "binder_linux"
            ]
            ++ lib.optionals hostSystem.hardware.amdgpu.enable ["amdgpu"];
          kernel.sysctl = {
            "kernel.unprivileged_userns_clone" = 1;
          };
          kernelParams = lib.mkIf hostSystem.hardware.amdgpu.enable [
            "amdgpu.ppfeaturemask=0xffffffff"
            "amdgpu.dpm=1"
          ];
        };
      };
    })
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

    # Hardware modules -> CONSOLIDATED INTO default.nix! 🔥
    # ./hardware

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
    # hyprland.nix (14 lines -> INLINED!)
    ({
      pkgs,
      config,
      ...
    }: {
      config = {
        programs.hyprland = {
          enable = true;
          xwayland.enable = true;
          package = pkgs.hyprland; # Use nixpkgs version for npins compatibility
          portalPackage = pkgs.xdg-desktop-portal-hyprland;
        };
      };
    })
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
    # mediamtx.nix (77 lines -> INLINED!)
    ({
      config,
      lib,
      pkgs,
      ...
    }: let
      port = "4200";
      localips = builtins.concatLists (
        builtins.map (iface: builtins.map (addr: addr.address) iface.ipv4.addresses) (
          builtins.attrValues config.networking.interfaces
        )
      );
      inherit (config.networking) nameservers;
      isIPv4 = addr: builtins.match "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$" addr != null;
      ipv4Nameservers = builtins.filter isIPv4 nameservers;
      getPublicIP = pkgs.writeShellScript "get-public-ip" ''
        ${pkgs.curl}/bin/curl -s https://api.ipify.org || echo "127.0.0.1"
      '';
    in {
      config = {
        services.mediamtx = {
          enable = true;
          settings = {
            api = true;
            apiAddress = "127.0.0.1:9997";
            rtsp = true;
            rtspAddress = ":8554";
            rtmp = true;
            rtmpAddress = ":1935";
            hls = true;
            hlsAddress = ":8080";
            hlsAllowOrigin = "*";
            webrtc = true;
            webrtcAddress = ":${port}";
            webrtcLocalUDPAddress = ":${port}";
            webrtcAdditionalHosts =
              ipv4Nameservers ++ localips;
            paths = {
              all_others = {};
            };
          };
        };
        networking.firewall = {
          allowedTCPPorts = [
            (lib.toInt port)
            8554
            1935
            8080
            9997
          ];
          allowedUDPPorts = [
            (lib.toInt port)
            8000
            8001
          ];
        };
        system.activationScripts.mediamtx-public-ip = {
          text = ''
            PUBLIC_IP=$(${getPublicIP})
            CONFIG_FILE="/etc/mediamtx.yaml"
            if [ -f "$CONFIG_FILE" ] && [ -n "$PUBLIC_IP" ] && [ "$PUBLIC_IP" != "127.0.0.1" ]; then
              echo "Updating MediaMTX with public IP: $PUBLIC_IP"
              ${pkgs.yq-go}/bin/yq eval ".webrtcAdditionalHosts += [\"$PUBLIC_IP\"]" "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
              mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
              if ${pkgs.systemd}/bin/systemctl is-active mediamtx.service >/dev/null 2>&1; then
                ${pkgs.systemd}/bin/systemctl restart mediamtx.service
              fi
            else
              echo "Could not determine public IP or config file not found"
            fi
          '';
        };
        environment.systemPackages = [
          pkgs.mediamtx
        ];
      };
    })
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
    # accounts.nix (24 lines -> INLINED!)
    ({
      config,
      pkgs,
      userConfigs,
      lib,
      ...
    }: {
      config = {
        users.users = lib.mkMerge [
          # Create users for each configured user
          (lib.genAttrs config.hostSystem.users (username: let
            userConfig = userConfigs.${username};
            systemConfig = userConfig.system or {};
          in {
            isNormalUser = systemConfig.isNormalUser or true;
            shell = pkgs.${systemConfig.shell or "zsh"};
            extraGroups = systemConfig.extraGroups or ["networkmanager" "video" "audio"];
            home = systemConfig.homeDirectory or "/home/${username}";

            ignoreShellProgramCheck = true;
          }))
        ];
      };
    })

    # Virtualization modules (consolidated from ./virtualization/default.nix)
    # android.nix (11 lines -> INLINED!)
    ({
      lib,
      hostSystem,
      ...
    }: {config = {virtualisation.waydroid = lib.mkIf (hostSystem.services.waydroid.enable or false) {enable = true;};};})
    # containers.nix (19 lines -> INLINED!)
    ({
      lib,
      config,
      hostSystem,
      ...
    }: {
      config = {
        virtualisation = {
          lxd.enable = true;
          docker = lib.mkIf (hostSystem.services.docker.enable or false) {
            enable = true;
            enableOnBoot = true;
          };
          podman = lib.mkIf (hostSystem.services.docker.enable or false) {
            enable = true;
          };
        };
      };
    })
  ];
}
