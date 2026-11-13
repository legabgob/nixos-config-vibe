{ config, pkgs, ... }:
{
  # Loads the NVIDIA driver; does not enable an X server.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam / Proton / Wine
    extraPackages = [ pkgs.nvidia-vaapi-driver ]; # VA-API video decode via NVDEC
  };

  hardware.nvidia = {
    # Open kernel modules: required for Blackwell (RTX 50), recommended from
    # Turing (RTX 20 / GTX 16) on. Set to false for Maxwell/Pascal (GTX 9xx/10xx),
    # and switch `package` below to nvidiaPackages.legacy_580 for those cards.
    open = true;

    modesetting.enable = true;

    # Saves VRAM across suspend; avoids a broken niri session after resume.
    powerManagement.enable = true;

    nvidiaSettings = true;

    # Built against whatever kernel boot.kernelPackages points to (the CachyOS
    # one here). Alternatives: .beta, .latest, .production.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # With the CachyOS kernel config, nixpkgs' kernel build also enables
  # nova_core (the new Rust NVIDIA driver), which can grab the GPU before
  # nvidia does. Harmless if the module does not exist.
  boot.blacklistedKernelModules = [ "nova_core" ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  # niri on NVIDIA: stop the driver from hoarding freed VRAM in the compositor
  # (~1 GiB instead of ~100 MiB). From niri's NVIDIA wiki page.
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
    builtins.toJSON {
      rules = [
        {
          pattern = {
            feature = "procname";
            matches = "niri";
          };
          profile = "Limit Free Buffer Pool On Wayland Compositors";
        }
      ];
      profiles = [
        {
          name = "Limit Free Buffer Pool On Wayland Compositors";
          settings = [
            {
              key = "GLVidHeapReuseRatio";
              value = 0;
            }
          ];
        }
      ];
    };

  environment.systemPackages = [ pkgs.nvtopPackages.nvidia ];
}
