# btrfs maintenance and /home snapshots. System rollback does not need
# snapshots on NixOS: every generation is a boot entry in Limine.
{
  config,
  lib,
  vars,
  ...
}:
let
  fsType = mount: config.fileSystems.${mount}.fsType or "";
in
lib.mkMerge [
  (lib.mkIf (fsType "/" == "btrfs") {
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  })

  # Hourly snapshots of /home, thinned out automatically.
  # Browse: `snapper -c home list`; restore a file from /home/.snapshots/<n>/snapshot/.
  (lib.mkIf (fsType "/home" == "btrfs") {
    # Snapper needs /home/.snapshots to be a subvolume. `v` creates it as a
    # nested subvolume if missing (graphical-installer layout) and leaves it
    # alone if it already exists (the disko layout mounts one there).
    systemd.tmpfiles.rules = [ "v /home/.snapshots 0750 root root -" ];

    services.snapper.configs.home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ vars.username ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 12;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 2;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  })
]
