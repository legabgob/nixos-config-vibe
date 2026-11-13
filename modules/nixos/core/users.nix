{ vars, ... }:
{
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.fullName;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
      "gamemode"
    ];
    # Login shell stays bash (the NixOS default); interactive bash execs fish,
    # as the NixOS wiki recommends. See home/shell.nix.
    # Set a password with `passwd` after the first boot, or uncomment:
    # initialPassword = "changeme";
  };

  # Still wanted with bash as login shell: puts NixOS's environment and the
  # completions shipped by system packages into fish.
  programs.fish.enable = true;
}
