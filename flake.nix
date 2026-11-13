{
  description = "NixOS: niri + Noctalia, NVIDIA, CachyOS kernel, CachyOS-style gaming, Zed + Python/Rust/R";

  # Binary caches for the CachyOS kernel and Noctalia. Used on the very first
  # build (pass --accept-flake-config); modules/nixos/core/nix.nix makes them
  # permanent afterwards.
  nixConfig = {
    extra-substituters = [
      "https://cache.lantian.pub/lantian"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # CachyOS kernels. The `release` branch only moves once Hydra has built and
    # cached the kernels. Do NOT make it follow nixpkgs: the patches are tied to
    # its own pin, and following would also defeat the binary cache.
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Noctalia v5 shell. Not following nixpkgs keeps noctalia.cachix.org usable.
    noctalia.url = "github:noctalia-dev/noctalia";

    # Declarative partitioning: the btrfs layout in hosts/<name>/disko.nix is
    # used both to format the disk at install time and to generate fileSystems.
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen browser (not in nixpkgs): package + Home Manager module.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Proton-CachyOS as a declarative Steam compatibility tool (auto-updated by Renovate).
    proton-cachy = {
      url = "github:Zariel/proton-cachy.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      disko,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      vars = import ./vars.nix;

      # One NixOS host = one directory in ./hosts with the same name.
      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs vars; };
          modules = [
            {
              networking.hostName = hostname;
              nixpkgs.hostPlatform = system;
            }
            disko.nixosModules.disko
            ./hosts/${hostname}
            ./modules/nixos

            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                extraSpecialArgs = { inherit inputs vars; };
                users.${vars.username} = import ./home;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        desktop = mkHost "desktop";
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
