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
    # networkmanager.nix (3 lines -> INLINED!)
    (_: {config = {networking.networkmanager.enable = true;};})
    ./networking/xdg-portal.nix

    # Programs modules (consolidated from ./programs/default.nix)
    ./programs/hyprland.nix
    ./programs/obs.nix

    # Security modules (consolidated from ./security/default.nix)
    # polkit.nix (3 lines -> INLINED!)
    (_: {config = {security.polkit.enable = true;};})
    # rtkit.nix (3 lines -> INLINED!)
    (_: {config = {security.rtkit.enable = true;};})
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
