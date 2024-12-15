{ config, pkgs, sharedVariable, ... }:

{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
    brews = [ ];
    casks = [
      "1password"
      "keepassxc"
      "appcleaner"
      "maccy"
      "rectangle"
      "snipaste"
      "brave-browser"
      # "firefox"
      "chatgpt"
      "thunderbird@esr"
      "typora"
      "visual-studio-code"
      "cursor"
      "fork"
      "insomnium"
      "bruno"
      "telegram"
      "wechat"
      "wechatwork"
      "localsend"
      "ddpm"
      "logi-options+"
      "spotify"
      "vmware-fusion"
      "docker"
    ];
  };

  environment.launchDaemons.mihomo = {
    enable = true;
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>mihomo</string>
        <key>ProgramArguments</key>
        <array>
          <string>${pkgs.mihomo}/bin/mihomo</string>
          <string>-d</string>
          <string>${config.users.users.${sharedVariable.user}.home}/.config/mihomo</string>
        </array>
        <key>KeepAlive</key>
        <true/>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>${config.users.users.${sharedVariable.user}.home}</string>
        <key>StandardOutPath</key>
        <string>${config.users.users.${sharedVariable.user}.home}/Library/Logs/mihomo.log</string>
        <key>StandardErrorPath</key>
        <string>${config.users.users.${sharedVariable.user}.home}/Library/Logs/mihomo.err</string>
      </dict>
      </plist>
    '';
    target = "mihomo.plist"; # 文件名
  };
}
