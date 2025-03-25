{
  description = "NixOS configuration";

  inputs = {
    # Define two different nixpkgs versions
    nixpkgs-24_11.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager-24_11 = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-24_11";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs@{ nixpkgs-24_11, nixpkgs-unstable, home-manager-24_11, home-manager-unstable, ... }: {
    nixosConfigurations = {
      simos = nixpkgs-24_11.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/simos/configuration.nix
          home-manager-24_11.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sheva = import ./hosts/simos/home.nix;
          }
        ];
      };

      athanasiou = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/athanasiou/configuration.nix
          home-manager-unstable.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sheva = import ./hosts/athanasiou/home.nix;
          }
        ];
      };
    };
  };
}
