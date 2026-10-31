{ pkgs ? import <nixpkgs> {}, fetchurl ? pkgs.fetchurl }:

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

    unpackPhase = ''
      mkdir -p $out/bin
      tar -xzf $src -C $out/bin
    '';

    installPhase = ''
      chmod +x $out/bin/hitomi-downloader
    '';

    meta = {
      description = "A downloader for hitomi.la";
      platforms = [ "x86_64-linux" ];
    };
  }