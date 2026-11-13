# The system tuning CachyOS ships in cachyos-settings / cachyos-ananicy-rules,
# translated to NixOS options.
{ pkgs, ... }:
{
  # NTSYNC: native NT sync primitives for Wine/Proton (Proton-CachyOS uses it).
  boot.kernelModules = [ "ntsync" ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 100; # tuned for zram, not disk swap
    "vm.vfs_cache_pressure" = 50;
    "vm.page-cluster" = 0;
    "vm.dirty_bytes" = 268435456;
    "vm.dirty_background_bytes" = 67108864;
    "vm.dirty_writeback_centisecs" = 1500;
    "vm.max_map_count" = 2147483642; # some games (e.g. CS2, Star Citizen) need it
    "kernel.nmi_watchdog" = 0;
    "kernel.split_lock_mitigate" = 0; # avoid split-lock stalls in some games
    "kernel.printk" = "3 3 3 3";
    "net.core.netdev_max_backlog" = 4096;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "fs.file-max" = 2097152;
  };

  # Compressed RAM swap sized like CachyOS (zram = RAM, zstd).
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
    priority = 100;
  };

  # Auto-nice daemon with the CachyOS rule set.
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  # sched_ext loader, the backend of CachyOS's scheduler switcher. No scheduler
  # is started by default (the kernel's own one is used); switch at runtime with
  # `scxctl start --sched lavd`, or set one here:
  services.scx-loader = {
    enable = true;
    # config.default_sched = "scx_lavd";
  };

  services.udev.extraRules = ''
    # I/O schedulers, as in CachyOS
    ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"

    # Let Wine/Proton open the NTSYNC device
    KERNEL=="ntsync", MODE="0644"
  '';

  services.fstrim.enable = true;
  services.irqbalance.enable = true;
}
