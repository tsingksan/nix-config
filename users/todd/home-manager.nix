{ sharedVariable }:

{ config, pkgs, lib, inputs, ... }:

let
  dotfiles = builtins.path {
    path = ../../dotfiles;
  };
in

{
  xdg.enable = true;

  # Home Manager 配置
  home = {
    username = sharedVariable.user;
    homeDirectory = "/Users/${sharedVariable.user}";
    stateVersion = "24.11";

    packages = with pkgs; [
      tmux
      fastfetch
      htop
      kitty

      # postgresql
      rustup
      zig
      zls
      go
      python3
      deno
      nodejs
      mihomo
    ] ++ (if sharedVariable.isDarwin then [
    ] else []);
  };

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FiSwX";
    RUSTUP_DIST_SERVER = "https://mirrors.tuna.tsinghua.edu.cn/rustup";
  };
  
  home.file = {
    ".gnupg/sshcontrol".source = "${dotfiles}/.gnupg/sshcontrol";
    ".ssh/authorized_keys".source = "${dotfiles}/.ssh/authorized_keys";
    ".ssh/config".source = "${dotfiles}/.ssh/config";
    ".zshrc".source = "${dotfiles}/.zshrc";
  };
  
  xdg.configFile = {
    "git/config".source = "${dotfiles}/.config/git/config";
    "kitty/current-theme.conf".source = "${dotfiles}/.config/kitty/current-theme.conf";
    "kitty/kitty.conf".source = "${dotfiles}/.config/kitty/kitty.conf";
    "npm/npmrc".source = "${dotfiles}/.config/npm/npmrc";
    "nvim".source = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "starter";
      rev = "main";
      sha256 = "sha256-SVpep7lVX0isYsUtscvgA7Ga3YXt/2jwQQCYkYadjiM=";
    };
    "tmux/tmux.conf".source = "${dotfiles}/.config/tmux/tmux.conf";
    "vim/viminfo".source = "${dotfiles}/.config/vim/viminfo";
    "vim/vimec".source = "${dotfiles}/.config/vim/vimec";
    "zsh".source = "${dotfiles}/.config/zsh";
    "zsh".recursive = true;
    "starship.toml".source = "${dotfiles}/.config/starship.toml";

  } // (if sharedVariable.isLinux then {
    "i3/config".text = builtins.readFile ./i3;
  } else {});

  # https://discourse.nixos.org/t/home-manager-xdg-xxx-env-vars-are-not-getting-created/49320/12
  programs.zsh.enable = true;
  
  home.sessionPath = [
    "${config.xdg.dataHome}/npm/bin"
    "${config.xdg.dataHome}/pnpm"
    "${config.xdg.dataHome}/go/bin"
  ] ++ (if sharedVariable.isDarwin then [
  ] else []);

  # set to true, the programs.gpg.package option will default to downloading pkgs.gnupg.
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = if sharedVariable.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-tty;

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 60480000;
    defaultCacheTtlSsh = 60480000;
    maxCacheTtl = 60480000;
    maxCacheTtlSsh = 60480000;
  };
}
