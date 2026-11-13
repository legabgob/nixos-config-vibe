# Zed, with language servers from nixpkgs so nothing depends on binaries Zed
# downloads itself (those still work thanks to nix-ld, see modules/nixos/dev.nix).
{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;

    # Installed by Zed on first start. Python and Rust support is built in.
    extensions = [
      "nix"
      "toml"
      "r"
      "make"
    ];

    # Added to Zed's PATH only.
    extraPackages = with pkgs; [
      nixd
      nixfmt
      basedpyright
      ruff
      rust-analyzer
    ];

    # Merged into ~/.config/zed/settings.json; changes made in the UI are kept.
    userSettings = {
      auto_update = false; # Nix manages the version
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      load_direnv = "shell_hook";
      ui_font_size = 16;
      buffer_font_size = 14;
      buffer_font_family = "JetBrainsMono Nerd Font";
      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark";
      };

      lsp = {
        rust-analyzer.binary.path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        nixd.binary.path = "${pkgs.nixd}/bin/nixd";
        basedpyright.binary = {
          path = "${pkgs.basedpyright}/bin/basedpyright-langserver";
          arguments = [ "--stdio" ];
        };
        ruff.binary = {
          path = "${pkgs.ruff}/bin/ruff";
          arguments = [ "server" ];
        };
      };

      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
          formatter.external.command = "nixfmt";
        };
        Python = {
          language_servers = [
            "basedpyright"
            "ruff"
            "!pyright"
            "!pylsp"
          ];
          formatter = [ { language_server.name = "ruff"; } ];
          format_on_save = "on";
        };
        Rust.format_on_save = "on";
      };
    };
  };
}
