# Optional KDE Plasma 6 session, for HDR (niri has no HDR support).
# Off by default. Turn it on in hosts/<name>/default.nix with
#   my.desktop.plasma.enable = true;
# then rebuild. At the tuigreet login, F3 lists the sessions; the last one
# picked is remembered, so choose niri again with F3 to go back.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktop.plasma;
in
{
  options.my.desktop.plasma.enable = lib.mkEnableOption "a KDE Plasma 6 session next to niri (for HDR)";

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    # Both the niri and the Plasma modules set this with mkDefault; niri stays
    # the default session.
    services.displayManager.defaultSession = "niri";

    # Plasma turns the Orca screen reader on by default.
    services.orca.enable = false;

    # Trim apps that duplicate what the niri side already has.
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      khelpcenter
      krdp
    ];

    # Plasma keeps its own display layout (rotation, positions, refresh rate,
    # HDR) in ~/.local/share/kscreen; set it once in System Settings > Display.
    #
    # Noctalia is bound to niri.service (home/desktop/noctalia.nix), so it does
    # not start inside Plasma. Plasma brings its own polkit agent and portal.
    # Note: gnome-keyring (from niri) and KWallet both exist; apps store
    # secrets in whichever answers in the session they run in.
  };
}
