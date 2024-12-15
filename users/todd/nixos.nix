{ config, pkgs, sharedVariable, ... }:

{
  users.users.${sharedVariable.user} = {
    isNormalUser = true;
    home = "/Users/${sharedVariable.user}";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$tKg08JXcXZ7H2dhW$bd1dEPD9ZM6XK2LkIX5bC0HjXerfkUxKEHMk8tIy/KssnE5mHJBtncmjRHfbF5tPDyDwNUMvOd9yfIohFdHBQ0";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5Hz44CGQ8CW2nN17ZWl1EQb2PNvusWU6cD9BD8tlmk tsingksan"
    ];
  };
}
