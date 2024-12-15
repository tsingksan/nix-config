{ pkgs, sharedVariable, ... }:

{
  nix = {
    channel.enable = false;
    settings = {
      use-xdg-base-directories = true;
      experimental-features = "nix-command flakes";
      # substituters = [
      #   "https://mirrors.ustc.edu.cn/nix-channels/store"
      #   "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      #   "https://cache.nixos.org/"
      # ];
      # trusted-public-keys = [
      #   "mirrors.ustc.edu.cn:UmPCkKFZlHGKKMEMW4Cambh2I6WDhQQCCwMD1YzuFRw="
      #   "mirrors.tuna.tsinghua.edu.cn:du5vxltwrm73p1l7qr4p0hglqkck2rqmqvh5psqh5xq="
      #   "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      # ];
    };
  };

  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    promptInit = "\n";
  };

  programs.bash = {
    completion.enable = false;
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    neovim
  ] ++ (lib.optionals sharedVariable.isDarwin [
    pinentry_mac
  ]) ++ (lib.optionals sharedVariable.isLinux [
    pinentry-tty
  ]) ++ lib.optionals (sharedVariable.currentSystemName == "vm-aarch64") [
    # This is needed for the vmware user tools clipboard to work.
    # You can test if you don't need this by deleting this and seeing
    # if the clipboard sill works.
    gtkmm3
  ];
  
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
  ];
}
