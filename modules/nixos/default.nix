# System-wide modules shared by every host.
{
  imports = [
    ./core
    ./hardware/nvidia.nix
    ./kernel
    ./desktop
    ./gaming
    ./dev.nix
  ];
}
