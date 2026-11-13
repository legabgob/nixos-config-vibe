# niri from nixpkgs. The compositor config itself is per-user: home/desktop/niri.
{ pkgs, ... }:
{
  # Session file, systemd units, gnome-keyring, xdg-desktop-portal-gnome/gtk.
  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    xwayland-satellite # niri starts it on demand for X11 apps (Steam, many games)
    wl-clipboard
    brightnessctl
    playerctl
  ];

  # Electron/Chromium apps on Wayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Trash, removable drives and MTP in file managers.
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
