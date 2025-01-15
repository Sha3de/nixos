{pkgs, ...}: let
  downloadPlugin = {
    name,
    version,
    url,
    hash,
  }:
    pkgs.stdenv.mkDerivation {
      inherit name version;
      src = pkgs.fetchzip {
        inherit url hash;
      };
      installPhase = ''
        mkdir -p $out
        cp -r . $out
      '';
    };

  #   catppuccin = downloadPlugin {
  #     name = "catppuccin";
  #     version = "3.4.0";
  #     url = "https://downloads.marketplace.jetbrains.com/files/18682/633467/Catppuccin_Theme-3.4.0.zip";
  #     hash = "sha256-a26wxw2/pJHt3SwNl0lzD/koKP77EhWpfNe3vw2rBco=";
  #   };
  github-theme = downloadPlugin {
    name = "github-theme";
    version = "1.2.2";
    url = "https://downloads.marketplace.jetbrains.com/files/15418/581904/GitHub_Theme-1.2.2.zip";
    hash = "sha256-LNhiblaW1Va5fF+/WwVl3Wb+Cm3dLCriKGHYgOr2Lr8=";
  };
in {
  home.packages = with pkgs; [
    (jetbrains.plugins.addPlugins jetbrains.datagrip [
      #   catppuccin
      "github-copilot"
      github-theme
    ])

    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [
      #   catppuccin
      "github-copilot"
      github-theme
    ])

    (jetbrains.plugins.addPlugins jetbrains.webstorm [
      #   catppuccin
      "github-copilot"
      github-theme
    ])
  ];
}
