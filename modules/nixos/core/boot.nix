{ lib, ... }:
{
  # Limine, like CachyOS. Every NixOS generation is a boot entry, which is the
  # NixOS equivalent of CachyOS's "boot into a snapper snapshot".
  # Switching bootloader later is just a rebuild; it only needs the ESP on /boot.
  boot.loader = {
    limine = {
      enable = true;
      maxGenerations = 10; # keeps the ESP from filling up
      # Secure Boot via sbctl, once keys are enrolled:
      # secureBoot.enable = true;
    };
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  boot.tmp.cleanOnBoot = true;

  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
