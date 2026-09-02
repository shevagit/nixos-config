{
  description = "NixOS configuration";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # simos-only graphics pin. simos (NVIDIA RTX 4070) login-loops on the
    # driver+kernel that nixpkgs-unstable currently ships (nvidia 595.91.07 /
    # kernel 7.2). This input is frozen at the last known-good nixpkgs revision
    # (nvidia 595.84 / kernel 7.1.5) and is used ONLY for simos's kernel (and,
    # via kernelPackages.nvidiaPackages.stable, its nvidia driver). It does not
    # affect the shared nixpkgs-unstable the other hosts build from.
    # See _plans/simos-nvidia-bump-hold.md. Bump this once nvidia > 595.84 lands.
    nixpkgs-simos-gfx.url = "github:nixos/nixpkgs/624af665418d3c65d544145b4d34ad696439570e";

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
    nixpkgs-simos-gfx,
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
      simos = let
        gfxPkgs = import nixpkgs-simos-gfx {
          inherit system;
          config.allowUnfree = true;
        };
      in mkHost {
        hostname = "simos";
        nixpkgs = nixpkgs-unstable;
        home-manager = home-manager-unstable;
        extraSpecialArgs = { inherit ags snitch; };
        nixosSpecialArgs = { inherit gfxPkgs; };
      };

      athanasiou = mkHost {
        hostname = "athanasiou";
        nixpkgs = nixpkgs-unstable;
        home-manager = home-manager-unstable;
      };

      nontas = mkHost {
        hostname = "nontas";
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
