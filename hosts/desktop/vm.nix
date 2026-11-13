# Overrides that only apply to `nixos-rebuild build-vm` / system.build.vm, for
# trying the config in QEMU on another Linux machine. The real system is not
# affected. See README, "Testing in a VM".
#
# What the VM does not test: the NVIDIA driver (no GPU inside the VM), Limine
# and the btrfs layout (the VM boots its kernel directly from a plain disk
# image), and the real monitor layout (one virtual screen).
{ lib, vars, ... }:
{
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192; # MiB
      cores = 8;
      diskSize = 16384; # MiB, holds /home and state; the store is shared from the host
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
