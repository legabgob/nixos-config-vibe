{
  lib,
  pkgs,
  vars,
  ...
}:
{
  # fish without making it the login shell (NixOS wiki, "Setting fish as
  # default shell"): bash stays the POSIX login shell, so ~/.profile, greetd and
  # scripts behave, and every interactive bash replaces itself with fish unless
  # its parent already is fish or it was started as `bash -c '...'`.
  # `bash --norc` still gives a plain bash.
  programs.bash = {
    enable = true;
    # mkOrder 100: hand over before bash loads completions, fzf, starship, etc.
    initExtra = lib.mkOrder 100 ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  # Makes `nix develop` / `nix-shell` open fish instead of bash. Without it the
  # snippet above would exec fish before the dev environment is loaded.
  programs.nix-your-shell.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting

      # fastfetch once per new kitty window (marker set in desktop/kitty.nix).
      if set -q FASTFETCH_ON_START
          set -e FASTFETCH_ON_START
          fastfetch
      end
    '';
    shellAbbrs = {
      rebuild = "nh os switch";
      update = "nh os switch --update";
    };
  };

  programs.starship = {
    enable = true;
    # Same prompt in bash and fish, so show which shell you are in, except
    # in fish (the normal case).
    settings.shell = {
      disabled = false;
      fish_indicator = "";
      bash_indicator = "bash ";
      format = "[$indicator]($style)";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = vars.fullName;
        email = vars.email;
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # GitHub CLI; also git's credential helper for github.com, so pushing to the
  # private config repo works after `gh auth login`.
  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  programs.ripgrep.enable = true;
  programs.fd.enable = true;
}
