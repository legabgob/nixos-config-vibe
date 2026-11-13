# Stable Rust from nixpkgs. Need nightly or several toolchains? Swap this for
# `pkgs.rustup` (works on NixOS thanks to nix-ld) or use rust-overlay/fenix in a
# project devShell.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rustc
    cargo
    clippy
    rustfmt
    rust-analyzer
    cargo-edit
    cargo-watch

    # Linker and common native deps for crates with C bindings
    gcc
    pkg-config
    openssl
  ];

  home.sessionVariables = {
    # std sources for rust-analyzer (the nixpkgs sysroot has none).
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

  home.sessionPath = [ "$HOME/.cargo/bin" ]; # `cargo install`ed tools
}
