{ pkgs ? import <nixpkgs> {}, appimageTools ? pkgs.appimageTools, fetchurl ? pkgs.fetchurl }:

let
  pname = "curseforge_updater";
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
      cp ${appimageContents}/curseforge.png $out/share/icons/hicolor/512x512/apps/curseforge.png

      substituteInPlace $out/share/applications/curseforge.desktop \
        --replace-warn "Exec=AppRun" "Exec=$out/bin/${pname}"
    '';

    meta = {
      description = "World of Warcraft Addon Updater";
      platforms = [ "x86_64-linux" ];
    };
  }