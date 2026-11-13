# NOT IMPORTED by default: the graphical installer path uses
# hardware-configuration.nix + filesystems.nix instead. Kept for a reinstall
# from the minimal ISO (README, "Alternative: disko").
#
# Disk layout, applied once at install time by disko and used on every
# rebuild to generate fileSystems. Changing it later does NOT reformat
# anything; it only changes what NixOS expects to mount.
#
# WARNING: running disko on this file wipes the whole disk below.
let
  # `ls -l /dev/disk/by-id/` on the installer; pick the nvme-... entry WITHOUT
  # a -partN suffix. A by-id path cannot silently point at the wrong drive.
  device = "/dev/disk/by-id/nvme-CHANGE-ME";

  btrfsOpts = [
    "compress=zstd:1"
    "noatime"
  ];
in
{
  disko.devices.disk.main = {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        # Limine copies every booted generation's kernel + initrd here, so give
        # it room (CachyOS kernel + NVIDIA initrd is ~60-80 MB per generation).
        ESP = {
          priority = 1;
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            # Flat layout: every subvolume sits at the top level and is mounted
            # explicitly, so / can be rolled back without touching the others.
            subvolumes = {
              "@" = {
                mountpoint = "/";
                mountOptions = btrfsOpts;
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = btrfsOpts;
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = btrfsOpts;
              };
              "@log" = {
                mountpoint = "/var/log";
                mountOptions = btrfsOpts;
              };
              # Snapper snapshots of /home (modules/nixos/core/btrfs.nix).
              # Game libraries are kept out of them by nested subvolumes,
              # see home/btrfs.nix.
              "@home-snapshots" = {
                mountpoint = "/home/.snapshots";
                mountOptions = btrfsOpts;
              };
            };
          };
        };
      };
    };
  };
}
