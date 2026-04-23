{ pkgs ? import <nixpkgs> {}, appimageTools ? pkgs.appimageTools, fetchurl ? pkgs.fetchurl }:

let
  pname = "curseForge_updater";
  version = "1.300.0.32036";

  src = fetchurl {
    url = "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.AppImage";
    hash = "sha256-wMAZwtbJ9eMtyFgVYuoVUEKzfDPuLOAWYXfIAItZgg8=";
  };

  appimageContents = appimageTools.extractType1 {
    inherit pname version src;
  };

in 
  appimageTools.wrapType2 rec {
    inherit pname version src;

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      mkdir -p $out/share/icons/hicolor/512x512/apps

      cp ${appimageContents}/curseforge.desktop $out/share/applications/curseforge.desktop

      substituteInPlace $out/share/applications/curseforge.desktop \
        --replace "Exec=Exec=AppRun --no-sandbox %U" "Exec=$out/bin/curseforge"
    '';

    meta = {
      description = "World of Warcraft Addon Updater";
      platforms = [ "x86_64-linux" ];
    };
  }