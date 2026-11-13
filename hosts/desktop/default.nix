# Machine-specific settings: i7-14700K + RTX 4070 SUPER desktop.
# Everything shared lives in ../../modules/nixos.
{ pkgs, vars, ... }:
{
  imports = [
    # Copied from /etc/nixos after installing with the graphical installer.
    ./hardware-configuration.nix
    # Mount options for the installer's btrfs layout.
    ./filesystems.nix

    # Alternative install path (declarative partitioning from the minimal
    # ISO): use ./disko.nix instead of ./filesystems.nix and generate the
    # hardware file with --no-filesystems. See README, "Alternative: disko".
    # ./disko.nix
  ];

  # CachyOS kernel flavour. Raptor Lake supports x86-64-v3 (AVX2) but not v4
  # (no AVX-512). `latest-lto` = CachyOS's default kernel: EEVDF scheduler,
  # Clang ThinLTO. Binary-cached alternatives for this CPU:
  #   linuxPackages-cachyos-latest-x86_64-v3      same, built with GCC
  #   linuxPackages-cachyos-bore-lto-x86_64-v3    BORE scheduler
  #   linuxPackages-cachyos-lts-lto-x86_64-v3     LTS series
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;

  # 13th/14th gen Core: load the latest microcode early (Vmin-shift fixes).
  # Also keep the BIOS updated; that is where Intel ships the main fix.
  hardware.cpu.intel.updateMicrocode = true;

  # KDE Plasma 6 as a second login session, for HDR (niri has none).
  # Set to true and rebuild; pick it at login with F3.
  my.desktop.plasma.enable = false;

  system.stateVersion = vars.stateVersion;
}
