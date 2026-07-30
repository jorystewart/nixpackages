{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "anker-powerconf-c200-linux-tools";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "erans";
    repo = "anker-powerconf-c200-linux-tools";
    tag = "v${finalAttrs.version}";
    # Run `nix-build -A ankerPowerconfC200LinuxTools` (or whatever attribute
    # name you call this package with via callPackage) once with this
    # placeholder in place; Nix will refuse to build and print the correct
    # hash to paste in here. Alternatively, if you have nix-prefetch-github
    # available: `nix-prefetch-github erans anker-powerconf-c200-linux-tools --rev v0.1.0`
    hash = "sha256-txIVTbqxnFQ8GcJgxTp89Qc3U5CXkYolXCO4E1PXHHA=";
  };

  # Plain C11 sources built directly against the Linux UVC/V4L2 kernel
  # headers (linux/videodev2.h, linux/uvcvideo.h, linux/usb/video.h) that
  # ship with stdenv on Linux -- no extra libraries are required.
  strictDeps = true;

  enableParallelBuilding = true;

  doCheck = true;
  checkTarget = "test";

  installPhase = ''
    runHook preInstall

    install -Dm755 build/anker-powerconf-c200-linux-tools -t $out/bin
    install -Dm444 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm444 LICENSE -t $out/share/licenses/${finalAttrs.pname}

    runHook postInstall
  '';

  meta = {
    description = "Linux CLI tools for vendor-specific controls (FOV, HDR, and more) on the Anker PowerConf C200 webcam";
    longDescription = ''
      Reverse-engineered command-line tools for the Anker PowerConf C200
      webcam that expose vendor-specific UVC extension-unit controls (field
      of view presets, HDR, horizontal flip, anti-flicker, etc.) which are
      not otherwise reachable through standard V4L2/UVC controls on Linux,
      alongside the standard controls exposed through the same CLI.
    '';
    homepage = "https://github.com/erans/anker-powerconf-c200-linux-tools";
    changelog = "https://github.com/erans/anker-powerconf-c200-linux-tools/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "anker-powerconf-c200-linux-tools";
  };
})
