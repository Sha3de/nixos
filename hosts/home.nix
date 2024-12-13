{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../home
  ];

  # Home Manager needs a bit of information about you and the paths it should
  home.username = "sha3de";
  home.homeDirectory = "/home/sha3de";

  # This value determines the Home Manager release that your configuration is
  targets.genericLinux.enable = true;
  home.activation = {
    linkDesktopApplications = {
      after = ["writeBoundary" "createXdgUserDirectories"];
      before = [];
      data = '''';
    };
  };

  # You should not change this value, even if you update Home Manager.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
