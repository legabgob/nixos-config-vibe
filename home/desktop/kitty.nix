# kitty, themed by Noctalia, with fastfetch on every new kitty window.
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    settings = {
      window_padding_width = 8;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      update_check_interval = 0;
    };

    # Marker for the fastfetch hook in home/shell.nix. Only shells started
    # directly by kitty get it, and the hook unsets it, so nested shells
    # (nix develop, Zed's terminal, a bash inside fish) stay quiet.
    environment.FASTFETCH_ON_START = "1";

    # Colours written by the Noctalia template in noctalia.nix on every
    # theme change (kitty is then reloaded live).
    extraConfig = ''
      include themes/noctalia.conf
    '';
  };

  programs.fastfetch.enable = true;
}
