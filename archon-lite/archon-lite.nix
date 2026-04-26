{ pkgs ? import <nixpkgs> {}, appimageTools ? pkgs.appimageTools, fetchurl ? pkgs.fetchurl }:

let
  pname = "archon-lite";
  version = "v9.0.131";

  src = fetchurl {
    url = "https://github.com/RPGLogs/Uploaders-archon/releases/download/${version}/archon-${version}.AppImage";
    hash = "sha256-NLoUozR9UaebSzOp5ACupg8AeURa3ZfNN7a2yV/xXSc=";
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

      cp "${appimageContents}/Archon App.desktop" "$out/share/applications/Archon App.desktop"
      cp "${appimageContents}/Archon App.png" "$out/share/icons/hicolor/512x512/apps/Archon App.png"

      substituteInPlace "$out/share/applications/Archon App.desktop" \
        --replace-warn "Exec=AppRun" "Exec=$out/bin/${pname}"
    '';

    meta = {
      description = "World of Warcraft Logs Uploader";
      platforms = [ "x86_64-linux" ];
    };
  }