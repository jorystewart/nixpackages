{ pkgs? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "randovania";
  version = "10.8.0";

  src = pkgs.fetchurl {
    url = "https://github.com/randovania/randovania/releases/download/v${version}/randovania-${version}-linux.tar.gz";
    hash = "sha256-mXUjyiaKqGGsyZNi96RX1bXWvCDZb63TOOfpsG1FT10="; 
  };

  nativeBuildInputs = [ pkgs.makeWrapper pkgs.copyDesktopItems pkgs.autoPatchelfHook ];

  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    glibc
    libx11
    libglvnd
    libdrm
    wayland
    libxcrypt-legacy
    SDL2
    lttng-ust
    xkeyboard-config
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    mkdir -p source
    tar xzf $src -C source --strip-components=1
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/randovania $out/bin
    cp -r source/* $out/opt/randovania/

    # Scrub the unstable optional dependencies
    rm -f $out/opt/randovania/_internal/data/dotnet_runtime/shared/Microsoft.NETCore.App/*/libcoreclrtraceptprovider.so
    rm -f $out/opt/randovania/_internal/PySide6/Qt/plugins/imageformats/libqtiff.so

    # This forces XWayland compatibility and feeds the correct XKB paths simultaneously
    makeWrapper $out/opt/randovania/randovania $out/bin/randovania \
      --set XKB_CONFIG_ROOT "${pkgs.xkeyboard_config}/share/X11/xkb" \
      --set QT_QPA_PLATFORM "xcb" \
      --set QT_LOGGING_RULES "*.debug=false"

    runHook postInstall
  '';

  desktopItems = [
      (pkgs.makeDesktopItem {
        name = "randovania";
        exec = "randovania";
        icon = "randovania";
        comment = "Randomizer platform for various games";
        desktopName = "Randovania";
        categories = [ "Game" ];
      })
    ];
}
