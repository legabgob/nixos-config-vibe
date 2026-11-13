# Game libraries as nested btrfs subvolumes. Snapshots are not recursive, so
# these are excluded from the hourly /home snapshots (otherwise every game update
# would stay pinned in old snapshots and fill the disk).
# `v` only creates the subvolume if the path does not exist yet; on a non-btrfs
# filesystem it falls back to a plain directory.
{
  systemd.user.tmpfiles.rules = [
    "v %h/.local/share/Steam - - - -"
    "v %h/Games - - - -"
  ];
}
