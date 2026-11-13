# The NixOS graphical installer, with "btrfs" picked, creates one btrfs
# partition with the root at the top level and two subvolumes, `home` and
# `nix`, and mounts them with compression during the install. The
# hardware-configuration.nix it generates only records `subvol=`, so these
# options are added here (NixOS merges them with the generated ones).
# Only valid for that layout: drop this import if you install on ext4.
let
  btrfsOpts = [
    "compress=zstd:1"
    "noatime"
  ];
in
{
  fileSystems."/".options = btrfsOpts;
  fileSystems."/home".options = btrfsOpts;
  fileSystems."/nix".options = btrfsOpts;
}
