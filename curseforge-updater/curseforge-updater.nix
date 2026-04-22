{ pkgs ? import <nixpkgs> {}, appimageTools ? pkgs.appimageTools, fetchurl ? pkgs.fetchurl }:

let
  pname = "CurseForge_Updater";
  version = "";

  src = fetchurl {
    url = "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.AppImage";
    hash = "sha256-wMAZwtbJ9eMtyFgVYuoVUEKzfDPuLOAWYXfIAItZgg8=";
  };

in 
  appimageTools.wrapType2 { inherit pname version src; }
