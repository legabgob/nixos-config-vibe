# Values shared by the NixOS and Home Manager sides. Edit these first.
{
  username = "gabriel";
  fullName = "Gabriel Chiche";
  email = "gabriel.chiche@unil.ch";

  timeZone = "Europe/Zurich";
  defaultLocale = "en_US.UTF-8";
  # Dates, units, paper size, currency.
  regionalLocale = "fr_CH.UTF-8";

  # Used by the TTY, the greeter and niri. US QWERTY. For French accents
  # without dead keys, variant "altgr-intl" puts them on AltGr (AltGr+e = é).
  keyboard = {
    layout = "us";
    variant = "";
  };

  # Monitor connector names. Fill in after the first login from
  # `niri msg outputs` (e.g. "DP-1", "DP-2", "HDMI-A-1"). The full
  # "Make Model Serial" string niri prints also works and survives swapping
  # ports. Until then niri places both screens on its own, often at 60 Hz.
  monitors = {
    main = "CHANGE-ME-OLED"; # 1440p OLED, landscape, on the right
    side = "CHANGE-ME-LCD"; # 1440p LCD, portrait, on the left
  };

  # The release you first installed with. Never bump it afterwards.
  stateVersion = "26.05";
}
