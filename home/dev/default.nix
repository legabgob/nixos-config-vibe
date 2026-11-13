# Global toolchains for quick work. For real projects prefer a per-project
# flake devShell + direnv (`use flake`), which pins versions per repo.
{
  imports = [
    ./python.nix
    ./rust.nix
    ./r.nix
  ];
}
