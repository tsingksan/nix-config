{ pkgs, ... }:

{
  imports = [
    ./hardware/vm-aarch64.nix
    ../shared/vm.nix
  ];

  # During system installation, ifconfig can be used to view the network configuration.
  networking.interfaces.ens160.useDHCP = true;
}
