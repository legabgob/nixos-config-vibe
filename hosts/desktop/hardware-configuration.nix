# PLACEHOLDER. After installing with the graphical installer, replace this
# whole file with the generated one:
#   cp /etc/nixos/hardware-configuration.nix hosts/desktop/hardware-configuration.nix
# It only exists so the flake evaluates. The filesystems mimic what the
# installer generates for btrfs (root at the top level, `home` and `nix`
# subvolumes, ESP at /boot); the UUIDs are fake.
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  warnings = [
    "hosts/desktop/hardware-configuration.nix is still the placeholder. Replace it with /etc/nixos/hardware-configuration.nix from the installed system."
  ];

  boot.initrd.availableKernelModules = [
    "vmd"
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "btrfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0000-0000";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];
}
