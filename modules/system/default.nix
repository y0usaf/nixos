{...}: {
  imports = [
    # Boot modules (consolidated from ./boot/default.nix)
    ./boot/kernel.nix
    ./boot/loader.nix

    # Core modules
    ./core

    # Hardware modules
    ./hardware

    # Networking modules (consolidated from ./networking/default.nix)
    ./networking/firewall.nix
    ./networking/networkmanager.nix
    ./networking/xdg-portal.nix

    # Programs modules (consolidated from ./programs/default.nix)
    ./programs/hyprland.nix
    ./programs/obs.nix

    # Security modules (consolidated from ./security/default.nix)
    ./security/polkit.nix
    ./security/rtkit.nix
    ./security/sudo.nix

    # Services modules (consolidated from ./services/default.nix)
    ./services/audio.nix
    ./services/dbus.nix
    ./services/mediamtx.nix
    ./services/scx.nix

    # Users modules (consolidated from ./users/default.nix)
    ./users/accounts.nix

    # Virtualization modules (consolidated from ./virtualization/default.nix)
    ./virtualization/android.nix
    ./virtualization/containers.nix
  ];
}
