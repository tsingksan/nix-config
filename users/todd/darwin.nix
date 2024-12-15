{ config, pkgs, sharedVariable, ... }:

{
  imports = [ ./homebrew.nix ];

  users.users.${sharedVariable.user}.home = "/Users/${sharedVariable.user}";

  # environment.variables = {
  # TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  # };
  # programs.nix-index.enable = true;


  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
}
