# Home Manager entry point for vars.username (wired up in flake.nix).
{ vars, ... }:
{
  imports = [
    ./shell.nix
    ./btrfs.nix
    ./desktop
    ./editor/zed.nix
    ./dev
  ];

  home = {
    username = vars.username;
    homeDirectory = "/home/${vars.username}";
    stateVersion = vars.stateVersion;
  };

  programs.home-manager.enable = true;
}
