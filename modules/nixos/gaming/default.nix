# NixOS translation of CachyOS's gaming meta-packages:
#   cachyos-gaming-meta          -> steam.nix (Proton-CachyOS, protontricks,
#                                   32-bit libs) + packages.nix (Wine, winetricks,
#                                   umu-launcher, Vulkan tools)
#   cachyos-gaming-applications  -> packages.nix (Lutris, Heroic, Faugus,
#                                   MangoHud, GOverlay) + tools.nix (gamescope)
# The CachyOS kernel tuning (ntsync, sysctls, zram, ananicy) is in ../kernel.
{
  imports = [
    ./steam.nix
    ./packages.nix
    ./tools.nix
  ];
}
