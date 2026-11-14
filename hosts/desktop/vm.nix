# Overrides that only apply to `nixos-rebuild build-vm` / system.build.vm, for
# trying the config in QEMU on another Linux machine. The real system is not
# affected. See README, "Testing in a VM".
#
# What the VM does not test: the NVIDIA driver (no GPU inside the VM), Limine
# and the btrfs layout (the VM boots its kernel directly from a plain disk
# image), and the real monitor layout (one virtual screen).
{
  lib,
  pkgs,
  vars,
  ...
}:
let
  # niri needs 3D acceleration in a VM (virgl), and virgl needs the host's
  # OpenGL driver. A Nix-built QEMU cannot load the NVIDIA driver of a non-NixOS
  # host, so the VM runs on the host's own QEMU instead (on Arch/CachyOS:
  # `pacman -S qemu-desktop`). On a NixOS host, set this to false.
  useHostQemu = true;

  hostQemu =
    pkgs.runCommand "host-qemu" { } ''
      mkdir -p $out/bin
      ln -s /usr/bin/qemu-system-x86_64 $out/bin/qemu-system-x86_64
      ln -s /usr/bin/qemu-img $out/bin/qemu-img
    ''
    # The VM runner reads the package's stdenv to pick the QEMU binary.
    // {
      inherit (pkgs) stdenv;
    };
in
{
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192; # MiB
      cores = 8;
      diskSize = 16384; # MiB, holds /home and state; the store is shared from the host
      qemu.package = lib.mkIf useHostQemu hostQemu;
      qemu.options = [
        # virtio GPU with virgl 3D, so niri and Noctalia get OpenGL ES.
        "-vga none"
        "-device virtio-vga-gl,xres=1920,yres=1080"
        "-display gtk,gl=on"
      ];
    };

    # No NVIDIA GPU in the VM: use Mesa's virgl driver instead.
    services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];

    # Fresh VM disk, so give the user a known password for tuigreet.
    users.users.${vars.username}.initialPassword = "vm";
  };
}
