{ pkgs, ... }:

{
  imports = [
    ./hardware/vm-aarch64.nix
    ../shared/vm.nix
  ];

  # During system installation, ifconfig can be used to view the network configuration.
  networking.interfaces.ens160.useDHCP = true;

  virtualisation.vmware.guest.enable = true;

  # Share our host filesystem
  fileSystems."/host" = {
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    device = ".host:/";
    options = [
      "umask=22"
      "uid=1000"
      "gid=1000"
      "allow_other"
      "auto_unmount"
      "defaults"
    ];
  };
}
