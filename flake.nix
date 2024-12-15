{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dotfiles = {
    #   url = "github:tsingksan/dotfiles";
    #   flake = false;
    # };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, nix-darwin, ... }:
    let
      mkConfig = import ./lib/mksystem.nix {
        inherit inputs;
      };
    in
    {
      nixosConfigurations.vm-aarch64 = nixpkgs.lib.nixosSystem (mkConfig {
        name = "vm-aarch64";
        system = "aarch64-linux";
      });

      nixosConfigurations.vm-x86_64 = nixpkgs.lib.nixosSystem (mkConfig {
        name = "vm-x86_64";
        system = "x86_64-linux";
      });

      darwinConfigurations.darwin-aarch64 = nix-darwin.lib.darwinSystem (mkConfig {
        name = "darwin-aarch64";
        system = "aarch64-darwin";
      });
    };
}
