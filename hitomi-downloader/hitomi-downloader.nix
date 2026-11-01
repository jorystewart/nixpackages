{ pkgs, fetchurl, copyDesktopItems, makeDesktopItem }:

let
  pname = "hitomi-downloader";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/lanyeeee/hitomi-downloader/releases/download/v${version}/${pname}_${version}_linux_amd64_portable.tar.gz";
    hash = "sha256-vCyr2Xtl6m5Ayzo58w6hHw6fmDDhgNJGtnuURDBMYAY=";
  };

in
  pkgs.stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [ copyDesktopItems ];

    unpackPhase = ''
      mkdir -p $out/bin
      tar -xzf $src -C $out/bin
    '';

    installPhase = ''
      chmod +x $out/bin/hitomi-downloader
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "Hitomi Downloader";
        exec = "hitomi-downloader";
        icon = "hitomi-downloader";
        comment = "A downloader for hitomi.la";
      })
    ];

    meta = {
      description = "A downloader for hitomi.la";
      platforms = [ "x86_64-linux" ];
    };
  }