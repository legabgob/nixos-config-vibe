# System side of Noctalia: package plus the services its widgets talk to
# (NetworkManager, Bluetooth, UPower, power-profiles-daemon).
# Its settings and the systemd user service are in home/desktop/noctalia.nix.
{ inputs, ... }:
{
  imports = [ inputs.noctalia.nixosModules.default ];

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };
}
