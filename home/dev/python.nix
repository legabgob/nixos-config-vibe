{ pkgs, ... }:
let
  python = pkgs.python3.withPackages (
    ps: with ps; [
      numpy
      pandas
      scipy
      matplotlib
      seaborn
      ipython
      ipykernel # Jupyter kernel, also used by Zed's REPL
      jupyterlab
      pytest
    ]
  );
in
{
  home.packages = [
    python
    pkgs.uv # venvs/projects: `uv venv`, `uv add`; wheels work through nix-ld
    pkgs.ruff
    pkgs.basedpyright
  ];

  # Let uv reuse the Nix Python instead of downloading its own builds.
  home.sessionVariables = {
    UV_PYTHON_DOWNLOADS = "never";
    UV_PYTHON = "${python}/bin/python3";
  };
}
