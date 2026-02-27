{
  description = "NixOS configuration";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # PINNED: 2026-02-27 — nixpkgs-unstable after a82ccc3 ships broken combo:
    # kernel 6.18.13 + nvidia 580.126.18 + weston 15 (SDDM crash + nvidia instability on simos/RTX 4070).
    # Last known working rev: a82ccc3 (kernel 6.18.10, nvidia 580.126.09, weston 14.0.1).
    # TODO: try `nix flake update` after ~2026-03-07 and rebuild simos to test if upstream fixed it.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    snitch = {
      url = "github:karol-broda/snitch";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs@{
    nixpkgs-stable,
    nixpkgs-unstable,
    home-manager-stable,
    home-manager-unstable,
    ags,
    snitch,
    sops-nix,
    ...
  }:
  let
    username = "sheva";
    system = "x86_64-linux";
    mkHost = { hostname, nixpkgs, home-manager, extraSpecialArgs ? {}, nixosSpecialArgs ? {} }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = nixosSpecialArgs;
        modules = [
          ./hosts/${hostname}/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./hosts/${hostname}/home.nix;
            home-manager.extraSpecialArgs = extraSpecialArgs;
          }
        ];
      };
  in
  {
    nixosConfigurations = {
      simos = mkHost {
        hostname = "simos";
        nixpkgs = nixpkgs-unstable;
        home-manager = home-manager-unstable;
        extraSpecialArgs = { inherit ags snitch; };
      };

      athanasiou = mkHost {
        hostname = "athanasiou";
        nixpkgs = nixpkgs-unstable;
        home-manager = home-manager-unstable;
      };

      kaleipo = let
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in mkHost {
        hostname = "kaleipo";
        nixpkgs = nixpkgs-stable;
        home-manager = home-manager-stable;
        nixosSpecialArgs = { inherit pkgs-unstable; };
      };
    };

    packages.${system} = nixpkgs-unstable.lib.mapAttrs'
      (hostname: config: {
        name = "homeConfigurations-${hostname}";
        value = config.config.home-manager.users.${username}.home.activationPackage;
      })
      inputs.self.nixosConfigurations;
  };
}
