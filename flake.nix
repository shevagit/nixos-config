{
  description = "nixos 24 with flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { nixpkgs, ... }:
    {
      nixosConfigurations = {
        # Define a configuration for your hostname
        simos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux"; # Replace if you're using a different architecture
          modules = [
            ./configuration.nix
          ];
        };
      };
    };
}
