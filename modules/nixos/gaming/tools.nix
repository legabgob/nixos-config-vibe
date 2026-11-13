{ pkgs, ... }:
{
  # Micro-compositor for games: `gamescope -W 2560 -H 1440 -r 165 -- %command%`.
  # capSysNice stays off: the setcap wrapper breaks gamescope started from Steam.
  programs.gamescope.enable = true;

  # `gamemoderun %command%` (Feral GameMode).
  programs.gamemode = {
    enable = true;
    settings.general.softrealtime = "auto";
  };

  # udev rules for most controllers (DualSense, Switch Pro, 8BitDo, ...).
  hardware.uinput.enable = true;
  services.udev.packages = [ pkgs.game-devices-udev-rules ];

  # Steam Controller / Index / Steam Deck controller rules.
  hardware.steam-hardware.enable = true;
}
