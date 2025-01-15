{pkgs, ...}: {
  programs.vscode = {
    enable = true;

    userSettings = {
      "files.autoSave" = "onFocusChange";
      "editor.formatOnSave" = true;
    };
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      github.copilot
      kamadorueda.alejandra
      dotjoshjohnson.xml
      leonardssh.vscord
    ];
    mutableExtensionsDir = false;
    package = pkgs.vscode;
  };
}
