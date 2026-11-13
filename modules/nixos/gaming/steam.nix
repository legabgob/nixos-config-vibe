{ inputs, pkgs, ... }:
let
  protonCachy = inputs.proton-cachy.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.steam = {
    enable = true;

    # Extra Proton builds, selectable per game in Steam > Properties > Compatibility.
    extraCompatPackages = [
      protonCachy.proton-cachyos-x86_64-v3 # Raptor Lake build; plain proton-cachyos for older CPUs
      pkgs.proton-ge-bin
    ];

    protontricks.enable = true;

    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    # Adds a "Steam Big Picture in gamescope" session (needs a session-picking
    # greeter to be useful; tuigreet here always starts niri).
    gamescopeSession.enable = false;
  };
}
