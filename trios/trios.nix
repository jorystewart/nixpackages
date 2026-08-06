{ lib
, stdenv
, makeDesktopItem
, fetchurl
, unzip
, autoPatchelfHook
, makeWrapper
, gtk3
, glib
, atk
, pango
, cairo
, harfbuzz
, gdk-pixbuf
, libepoxy
, fontconfig
, curl
, zlib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "trios";
  version = "1.6.1";

  src = fetchurl {
    url = "https://github.com/wispborne/TriOS/releases/download/${finalAttrs.version}/TriOS-linux.zip";
    hash = "sha256-Nksy+SBfUsV5z6aHCco2LIjTGG3GZhs7PxHrXiWYQE8=";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    gtk3
    glib
    atk
    pango
    cairo
    harfbuzz
    gdk-pixbuf
    libepoxy
    fontconfig
    curl
    zlib
    stdenv.cc.cc.lib
  ];

  # I'm not sure this is actually needed and I really don't want to mess with JVM if I don't have to
  autoPatchelfIgnoreMissingDeps = [ "libjvm.so" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/trios $out/bin
    cp -r . $out/opt/trios/
    chmod +x $out/opt/trios/TriOS

    makeWrapper $out/opt/trios/TriOS $out/bin/trios \
      --chdir $out/opt/trios

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "TriOS";
      exec = "TriOS";
      icon = "TriOS";
      comment = "TriOS - Starsector Mod Manager";
      desktopName = "TriOS";
    })
  ];

  meta = {
    description = "Starsector Mod Manager";
    homepage = "https://github.com/wispborne/TriOS";
    # Uses a custom license that is very slightly modified from Apache 2.0.
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "TriOS";
  };
})
