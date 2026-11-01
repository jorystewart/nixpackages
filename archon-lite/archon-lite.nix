{ pkgs ? import <nixpkgs> {}, appimageTools ? pkgs.appimageTools, fetchurl ? pkgs.fetchurl }:

let
  pname = "archon-lite";
  version = "9.6.223";

  src = fetchurl {
    url = "https://github.com/RPGLogs/Uploaders-archon/releases/download/v${version}/archon-v${version}.AppImage";
    hash = "sha256-KO2Mdh11ceuxw1DqqyMfyu3cvlaNXH3oNU10XB9TUoU=";
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

      cp "${appimageContents}/archon.desktop" "$out/share/applications/archon.desktop"
      cp "${appimageContents}/archon.png" "$out/share/icons/hicolor/512x512/apps/archon.png"

      substituteInPlace "$out/share/applications/archon.desktop" \
        --replace-warn "Exec=AppRun" "Exec=$out/bin/${pname}"
    '';

    meta = {
      description = "World of Warcraft Logs Uploader";
      platforms = [ "x86_64-linux" ];
    };
  }
