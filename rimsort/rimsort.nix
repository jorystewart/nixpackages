{ appimageTools, fetchurl }:

let
  pname = "rimsort";
  version = "v1.8.0";

  src = fetchurl {
    url = "https://github.com/RimSort/RimSort/releases/download/${version}/RimSort-${version}-x86_64.AppImage";
    hash = "sha256-VPCvOBjFdjZ0Ycny29854JoRHOlGvLW16fzft7/RJws=";
  };

  appimageContents = appimageTools.extractType1 {
    inherit pname version src;
  };

in 
  appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: with pkgs; [ 
      zstd
      libxkbfile  ];

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      mkdir -p $out/share/icons/hicolor/512x512/apps

      cp "${appimageContents}/io.github.rimsort.RimSort.desktop" "$out/share/applications/RimSort.desktop"
      cp "${appimageContents}/io.github.rimsort.RimSort.svg" "$out/share/icons/hicolor/512x512/apps/RimSort.svg"

      substituteInPlace "$out/share/applications/RimSort.desktop" \
        --replace-warn "Exec=RimSort" "Exec=$out/bin/${pname}" \
    '';

    meta = {
      description = "RimWorld mod manager";
      platforms = [ "x86_64-linux" ];
    };
  }