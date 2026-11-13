{ vars, ... }:
{
  time.timeZone = vars.timeZone;

  i18n = {
    defaultLocale = vars.defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = vars.regionalLocale;
      LC_MEASUREMENT = vars.regionalLocale;
      LC_MONETARY = vars.regionalLocale;
      LC_NUMERIC = vars.regionalLocale;
      LC_PAPER = vars.regionalLocale;
      LC_TELEPHONE = vars.regionalLocale;
      LC_TIME = vars.regionalLocale;
    };
  };

  # Keyboard layout for the TTY and the greeter (niri reads vars.keyboard too).
  services.xserver.xkb = {
    inherit (vars.keyboard) layout variant;
  };
  console.useXkbConfig = true;
}
