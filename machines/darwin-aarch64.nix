{ pkgs, lib, sharedVariable, ... }:

{
  imports = [
    ../shared/common.nix
  ];

  system.stateVersion = 5;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
}
