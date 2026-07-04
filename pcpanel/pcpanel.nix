{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, copyDesktopItems
, libusb1
, zlib
, glib
, gtk3
, cairo
, pango
, atk
, gdk-pixbuf
, fontconfig
, freetype
, dbus
, at-spi2-core
, libx11
, libxext
, libxrender
, libxtst
, libxi
, udev # provides libudev.so.1 — hid4java/JNA dlopen's this by name at runtime (not a static link, so autoPatchelf can't catch it; wired via LD_LIBRARY_PATH below)
, kdotool
, xdotool
, pulseaudio
}:

let
  version = "2.0.71";
  debFileName = "pcpanel_${version}_amd64.deb";
  releaseTag = "latest-main";
in
stdenv.mkDerivation {
  pname = "pcpanel";
  inherit version;

  src = fetchurl {
    url = "https://github.com/nvdweem/PCPanel/releases/download/${releaseTag}/${debFileName}";
    sha256 = "sha256-TCQQthPJCm4iPmCTJbDkG2maL1JJCG4rDrvtOW3wThM=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    stdenv.cc.cc.lib # libstdc++
    zlib
    libusb1 # libusb-1.0.so.0 — required for HID device access (documented dependency)
    glib
    gtk3
    cairo
    pango
    atk
    gdk-pixbuf
    fontconfig
    freetype
    dbus
    at-spi2-core
    libx11
    libxext
    libxrender
    libxtst
    libxi
  ];

  # Cheat and repackage the .deb instead of building from source
  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/opt/pcpanel" "$out/bin" "$out/lib/udev/rules.d"

    cp -r opt/pcpanel/. "$out/opt/pcpanel/"

    # Desktop entry + icons
    if [ -d usr/share/applications ]; then
      mkdir -p "$out/share/applications"
      cp -r usr/share/applications/. "$out/share/applications/"
      substituteInPlace "$out"/share/applications/*.desktop \
        --replace-quiet "/opt/pcpanel/PCPanel" "$out/bin/pcpanel" || true
    fi
    if [ -d usr/share/icons ]; then
      mkdir -p "$out/share/icons"
      cp -r usr/share/icons/. "$out/share/icons/"
    fi

    # Udev rules: install them into the store so they can be picked up via
    # `services.udev.packages` in your NixOS configuration (see the
    # accompanying configuration-snippet.nix). We also hardcode upstream's
    # documented rule content as a fallback in case the .deb's copy isn't
    # found at this path.
    if [ -f usr/lib/udev/rules.d/70-pcpanel.rules ]; then
      cp usr/lib/udev/rules.d/70-pcpanel.rules "$out/lib/udev/rules.d/"
    else
      cat > "$out/lib/udev/rules.d/70-pcpanel.rules" <<'EOF'
SUBSYSTEM=="usb", ATTRS{idVendor}=="04D8", ATTRS{idProduct}=="eb52", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a3c4", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="a3c5", TAG+="uaccess"
EOF
    fi

    # Wrapper: expose `pcpanel` on PATH, make sure the runtime helper tools
    # the app shells out to are found — `pactl` for volume control and
    # `kdotool` for focus-window detection under KDE/Wayland (as documented
    # in linux.md; `xdotool` included as an X11/XWayland fallback) — and set
    # LD_LIBRARY_PATH so hid4java/JNA's runtime dlopen("libudev.so.1") can
    # find it. This is a plain dlopen-by-name at runtime, not a static ELF
    # dependency, so autoPatchelfHook has no NEEDED entry to patch a rpath
    # for; LD_LIBRARY_PATH is the mechanism dlopen-by-bare-name honors.
    chmod +x "$out/opt/pcpanel/PCPanel"
    makeWrapper "$out/opt/pcpanel/PCPanel" "$out/bin/pcpanel" \
      --prefix PATH : ${lib.makeBinPath [ pulseaudio kdotool xdotool ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ udev ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Third-party controller software for PCPanel USB desk controllers";
    longDescription = ''
      Open-source alternative to the official PCPanel software.
    '';
    homepage = "https://github.com/nvdweem/PCPanel";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    mainProgram = "pcpanel";
  };
}
