{
  # NetworkManager, Bluetooth, UPower and power-profiles-daemon are also
  # requested by Noctalia (desktop/noctalia.nix); they are set here explicitly
  # so the system does not depend on that module for basic connectivity.
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.resolved.enable = true;
  services.openssh.enable = false;
}
