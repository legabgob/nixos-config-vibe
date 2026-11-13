# Small system-wide toolset. User-facing apps live in ../../../home.
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    unzip
    p7zip
    file
    pciutils
    usbutils
    lm_sensors
    htop
    btop
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };
}
