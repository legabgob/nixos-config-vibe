# Installs ./config.kdl as ~/.config/niri/config.kdl, with the keyboard layout
# and monitor names from vars.nix filled in and the result validated by niri at
# build time, so a typo fails the rebuild instead of breaking the session.
{
  lib,
  osConfig,
  pkgs,
  vars,
  ...
}:
let
  niri = osConfig.programs.niri.package;

  rendered = pkgs.writeText "niri-config.kdl" (
    builtins.replaceStrings
      [
        "@kbLayout@"
        "@kbVariant@"
        "@mainOutput@"
        "@sideOutput@"
      ]
      [
        vars.keyboard.layout
        vars.keyboard.variant
        vars.monitors.main
        vars.monitors.side
      ]
      (builtins.readFile ./config.kdl)
  );

  validated = pkgs.runCommand "niri-config-validated.kdl" { } ''
    ${niri}/bin/niri validate --config ${rendered}
    cp ${rendered} $out
  '';
in
{
  xdg.configFile."niri/config.kdl".source = validated;

  # Wayland user services managed by Home Manager (Noctalia here) start with
  # niri and stop with it, instead of with any graphical session. Keeps the
  # bar/notifications out of the optional Plasma session.
  wayland.systemd.target = "niri.service";

  warnings = lib.optional (lib.any (lib.hasPrefix "CHANGE-ME") (lib.attrValues vars.monitors)) ''
    vars.monitors still has placeholder names, so the niri output layout
    (rotation, position, refresh rate) is not applied. Fill them in from
    `niri msg outputs`.
  '';
}
