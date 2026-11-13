# R with a fixed package library. Packages are added here (rPackages.<name>,
# dots become underscores: data.table -> data_table), not with install.packages().
{ pkgs, ... }:
let
  rPkgs = with pkgs.rPackages; [
    languageserver # used by Zed's R extension
    lintr
    styler
    httpgd # plots in a browser/Zed preview: hgd()

    tidyverse
    data_table
    here
    renv
    devtools
    rmarkdown
    knitr
  ];
in
{
  home.packages = [
    (pkgs.rWrapper.override { packages = rPkgs; })
    (pkgs.radianWrapper.override { packages = rPkgs; }) # nicer R console
    pkgs.quarto
  ];
}
