{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Launchers (cachyos-gaming-applications)
    lutris
    heroic
    faugus-launcher

    # Overlay and its GUI (cachyos-gaming-applications)
    mangohud
    goverlay

    # Wine stack (cachyos-gaming-meta). wine-cachyos has no Nix package;
    # wine-staging WoW64 is the closest, Proton-CachyOS covers Steam/umu.
    wineWow64Packages.staging
    winetricks
    umu-launcher

    # Proton manager for anything not declared in steam.nix
    protonplus

    # Diagnostics
    vulkan-tools
    mesa-demos
  ];
}
