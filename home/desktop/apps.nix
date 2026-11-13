# Everyday desktop apps referenced by the niri keybinds.
{ inputs, pkgs, ... }:
{
  imports = [
    ./kitty.nix
    inputs.zen-browser.homeModules.beta
  ];

  # Zen (Firefox-based). Binary and app-id: zen-beta.
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    policies = {
      DisableAppUpdate = true; # Nix updates it
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
    };
  };
  xdg.mimeApps.enable = true; # needed for setAsDefaultBrowser to take effect

  home.packages = with pkgs; [
    nautilus
    loupe # images
    papers # PDFs
    mpv
    file-roller
    pavucontrol
  ];

  # Dark GTK/Qt apps to match Noctalia's dark theme.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
