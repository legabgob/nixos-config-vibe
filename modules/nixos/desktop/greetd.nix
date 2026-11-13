# Login: greetd + tuigreet. niri (via niri-session) is the default; F3 lists
# every installed Wayland session (Plasma too, when my.desktop.plasma is on)
# and the last choice is remembered.
# A themed alternative is nixpkgs' noctalia-greeter: replace this file's body with
#   services.displayManager.noctalia-greeter.enable = true;
{
  config,
  lib,
  pkgs,
  ...
}:
let
  niriSession = lib.getExe' config.programs.niri.package "niri-session";
  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
in
{
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      command = lib.concatStringsSep " " [
        (lib.getExe pkgs.tuigreet)
        "--time"
        "--asterisks"
        "--remember"
        "--remember-session"
        "--sessions ${sessions}"
        "--cmd ${niriSession}"
      ];
      user = "greeter";
    };
  };
}
