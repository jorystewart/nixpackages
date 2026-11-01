{ lib
, stdenv
, fetchurl
, makeWrapper
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
      makeWrapper
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

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      install -Dm755 hitomi-downloader $out/bin/hitomi-downloader

      runHook postInstall
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1
        )
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