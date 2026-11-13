# CachyOS kernel from github:xddxdd/nix-cachyos-kernel.
{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  # `pinned` builds the kernels with the flake's own nixpkgs revision, which is
  # what its Hydra populates the binary cache with. Exposes pkgs.cachyosKernels.*.
  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];

  # Fallback for hosts that do not pick a flavour (see hosts/<name>/default.nix).
  boot.kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest;
}
