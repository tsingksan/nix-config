{ inputs }:

{ name, system }:

let
  pkgs = import inputs.nixpkgs {
    inherit system;
  };

  user = "todd";
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isAarch64;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  currentSystemName = name;
  sharedVariable = {
    inherit user isDarwin isLinux currentSystemName;
  };

  machineConfig = ../machines/${name}.nix;
  userOSConfig = ../users/${user}/${if isDarwin then "darwin" else "nixos"}.nix;
  userHMConfig = ../users/${user}/home-manager.nix;

  homeManagerFunc = if isDarwin then inputs.home-manager.darwinModules.home-manager else inputs.home-manager.nixosModules.home-manager;
in

rec {
  modules = [
    machineConfig
    userOSConfig

    homeManagerFunc
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${user} = import userHMConfig { inherit sharedVariable; };
      };
    }

    {
      config._module.args = {
        inherit sharedVariable;
      };
    }

  ];

}
