{ lib
, stdenv
, fetchurl
, copyDesktopItems
, makeDesktopItem
, autoPatchelfHook
, wrapGAppsHook3
, openssl
, webkitgtk_4_1
, gtk3
, cairo
, gdk-pixbuf
, libsoup_3
, glib
}:

let
  pname = "hitomi-downloader";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/lanyeeee/hitomi-downloader/releases/download/v${version}/${pname}_${version}_linux_amd64_portable.tar.gz";
    hash = "sha256-vCyr2Xtl6m5Ayzo58w6hHw6fmDDhgNJGtnuURDBMYAY=";
  };

in
  stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
      wrapGAppsHook3
    ];

    buildInputs = [
      openssl
      webkitgtk_4_1
      gtk3
      cairo
      gdk-pixbuf
      libsoup_3
      glib
      stdenv.cc.cc.lib
    ];

    unpackPhase = ''
      mkdir -p $out/hitomi-downloader
      tar -xzf $src -C $out/hitomi-downloader
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      install -m755 $out/hitomi-downloader/hitomi-downloader $out/bin/hitomi-downloader

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "Hitomi Downloader";
        exec = "hitomi-downloader";
        icon = "hitomi-downloader";
        comment = "A downloader for hitomi.la";
        desktopName = "Hitomi Downloader";
      })
    ];

    meta = {
      description = "A downloader for hitomi.la";
      homepage = "https://github.com/lanyeeee/hitomi-downloader";
      platforms = [ "x86_64-linux" ];
      license = lib.licenses.mit;
    };
  }