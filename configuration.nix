#===============================================================================
#                          🖥️ NixOS Configuration 🖥️
#===============================================================================
# 🔧 Core system settings
# 📦 Package management
# 🛠️ Hardware configuration
# 🔒 Security settings
# 👤 User environment
# 🚀 Services & programs
# 🌐 Network & virtualization
#
# ⚠️  Root access required | System rebuild needed for changes
#===============================================================================
{
  config,
  lib,
  pkgs,
  globals,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./env.nix
    ./cachix.nix
  ];

  # SCX Module definition
  options.scx = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables the scx service and configuration.";
    };

    scheduler = lib.mkOption {
      type = lib.types.str;
      default = "scx_lavd";
      description = "Change the scheduler used by scx.";
    };
  };

  # Configuration
  config = {
    system.stateVersion = globals.stateVersion;
    time.timeZone = globals.timezone;
    networking.hostName = globals.hostname;

    nixpkgs.config.allowUnfree = true;

    nix = {
      package = pkgs.nixVersions.stable;
      settings = {
        auto-optimise-store = true;
        max-jobs = "auto";
        cores = 0;
        system-features = ["big-parallel" "kvm" "nixos-test"];
        sandbox = true;
        trusted-users = ["root" globals.username];
        builders-use-substitutes = true;
        fallback = true;
      };
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 20;
        };
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
      };
      kernelPackages = pkgs.linuxPackages_latest;
      kernelModules = [
        "kvm-amd"
        "k10temp" # AMD CPU temperature
        "nct6775" # Motherboard sensors
      ];
    };

    #── 🎮 Graphics & Display ─────────────────#
    hardware = {
      nvidia = lib.mkIf globals.enableNvidia {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
      };
      i2c.enable = true;
    };

    services.xserver.videoDrivers = lib.mkIf globals.enableNvidia ["nvidia"];

    #── 🔊 Audio Configuration ────────────────#
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    #── 🔒 Security & Permissions ────────────#
    security = {
      polkit = {
        enable = true;
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.policykit.exec" &&
                action.lookup("command_line").indexOf("nvidia-smi") >= 0) {
                return polkit.Result.YES;
            }
          });
        '';
      };
      sudo.extraRules = [
        {
          users = [globals.username];
          commands = [
            {
              command = "ALL";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };

    #── 👤 User Environment ─────────────────#
    users.users.${globals.username} = {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "gamemode"
        "input"
      ];
      ignoreShellProgramCheck = true;
    };

    #── 📦 System Packages ──────────────────#
    environment = {
      systemPackages = with pkgs; [
        # Basic utilities
        git
        vim
        curl
        wget
        cachix
        unzip
        lm_sensors
        yt-dlp-light
        bash
        # Python with packages
        (python3.withPackages (ps:
          with ps; [
            pip
            setuptools
          ]))
        python3
      ];

      # Sensor configuration
      etc."sensors.d/nvidia.conf".text = ''
        chip "nvidia-*"
          label temp1 "GPU Temperature"
          label fan1 "GPU Fan Speed"
          set temp1_max 95
          set temp1_crit 105
      '';
    };

    #── 🚀 Services & Programs ───────────────#
    xdg.portal = lib.mkIf globals.enableWayland {
      enable = true;
      wlr.enable = false;
      extraPortals = lib.optionals globals.enableHyprland [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config = lib.mkIf globals.enableHyprland {
        common.default = ["hyprland"];
        hyprland = {
          default = ["hyprland"];
          "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
          "org.freedesktop.impl.portal.Screencast" = ["hyprland"];
        };
      };
    };

    programs = {
      zsh = {
        enable = false;
        enableGlobalCompInit = false;
      };
      dconf.enable = true;
    };

    services.dbus.packages = [pkgs.dconf];

    #── 🔌 Device Rules ────────────────────#
    services.udev.extraRules = ''
      # Vial rules for non-root access to keyboards
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", TAG+="uaccess"
    '';

    #── 🌐 Network & Virtualization ─────────#
    networking.networkmanager.enable = true;
    virtualisation.lxd.enable = true;

    #── 📦 SCX Configuration ────────────────#
    services.scx = lib.mkIf config.scx.enable {
      enable = true;
      scheduler = config.scx.scheduler;
      package = pkgs.scx.rustscheds;
    };
  };
}
