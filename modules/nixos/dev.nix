# System-level pieces of the dev setup. The toolchains themselves are per-user
# (home/dev/*.nix).
{ pkgs, ... }:
{
  # Lets non-Nix binaries find their libraries: language servers Zed downloads
  # on its own, Python wheels installed with uv/pip, rustup toolchains, etc.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      zstd
      bzip2
      xz
      openssl
      curl
      libffi
      libGL
      glib
      libxkbcommon
      fontconfig
      freetype
      icu
    ];
  };

  # direnv + nix-direnv (per-project `use flake`) is enabled per user in home/shell.nix.
}
