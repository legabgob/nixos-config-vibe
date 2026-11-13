# Noctalia v5 settings, written to ~/.config/noctalia/config.toml and checked
# with `noctalia config validate` at build time. Anything changed in the
# Settings GUI is stored as an override on top of this file.
# Reference: https://docs.noctalia.dev/noctalia/configuration/
{
  config,
  inputs,
  pkgs,
  vars,
  ...
}:
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;

    # Started with niri.service (see niri/default.nix), restarted on config change.
    systemd.enable = true;

    settings = {
      shell = {
        font_family = "Inter";
        # Apps launched from Noctalia survive a shell restart (needs systemd.enable).
        launch_apps_as_systemd_services = true;
        # niri ships no polkit agent; use Noctalia's.
        polkit_agent = true;
        telemetry_enabled = false;
      };

      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Noctalia";

        # kitty colours follow the Noctalia palette. Same input as Noctalia's
        # built-in kitty template, but declared as a user template: the
        # built-in one edits kitty.conf, which is read-only here (the include
        # is in kitty.nix instead). kitty reloads its config on SIGUSR1.
        templates.user.kitty-hm = {
          input_path = "${config.programs.noctalia.package}/share/noctalia/assets/templates/kitty/kitty.conf";
          output_path = "$XDG_CONFIG_HOME/kitty/themes/noctalia.conf";
          post_hook = "${pkgs.procps}/bin/pkill -USR1 kitty";
        };
      };

      # OLED burn-in: the bar is the only always-on static element, so on the
      # OLED it only shows on empty workspaces ("smart" auto-hide). The LCD
      # keeps a permanent bar.
      bar.default.monitor.oled = {
        match = vars.monitors.main;
        smart_auto_hide = true;
      };

      # Blurred wallpaper copy behind niri's overview (matching layer-rule in config.kdl).
      backdrop.enabled = true;

      # Lock after 10 min idle, screen off after 11.
      idle.behavior = {
        lock = {
          enabled = true;
          timeout = 600;
          action = "lock";
        };
        screen-off = {
          enabled = true;
          timeout = 660;
          action = "screen_off";
        };
      };

      # wallpaper.default.path = "/home/you/Pictures/wallpaper.png";
    };
  };
}
