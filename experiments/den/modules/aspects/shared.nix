{
  den,
  inputs,
  ...
}: {
  den.aspects.linux-base = {
    nixos = {
      imports = [
        ../../../../nixos
      ];
    };
  };

  den.aspects.darwin-base = {
    darwin = {
      imports = [
        ../../../../darwin
        inputs.home-manager.darwinModules.home-manager
      ];
    };
  };

  den.aspects.linux-workstation.nixos = {
    services = {
      docker.enable = true;
      waydroid.enable = false;
      controllers.enable = true;
      tailscale.enableVPN = true;
    };
  };

  den.aspects.linux-portable.nixos = {
    services.syncthing-proxy.enable = true;
  };

  den.aspects.linux-server.nixos = {
    core.graphicalDesktop.headless = true;
    services = {
      docker.enable = true;
      waydroid.enable = false;
      tailscale.enableVPN = true;
    };
  };

  den.aspects.gpu-nvidia.nixos = {
    hardware = {
      nvidia = {
        enable = true;
        cuda.enable = true;
      };
      amdgpu.enable = false;
    };
  };

  den.aspects.gpu-amdgpu.nixos = {
    hardware = {
      nvidia.enable = false;
      amdgpu.enable = true;
    };
  };

  den.aspects.cpu-amd.nixos.hardware.cpu.amd.enable = true;

  den.aspects.cpu-intel.nixos.hardware.cpu.intel.enable = true;

  den.aspects.syncthing-proxy.nixos.services.syncthing-proxy.enable = true;
}
