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
    postExtract = ''
      substituteInPlace $out/curseforge.desktop --replace-fail 'Exec=AppRun' 'Exec=curseforge'
    '';
  };

in 
  appimageTools.wrapType2 rec {
    inherit pname version src;

    meta = {
      description = "World of Warcraft Addon Updater";
      platforms = [ "x86_64-linux" ];
    };
  }