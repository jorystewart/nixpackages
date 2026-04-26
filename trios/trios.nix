{ pkgs ? import <nixpkgs> {} }:
let

  inherit (pkgs) lib stdenv fetchFromGitHub makeDesktopItem copyDesktopItems flutter;

  pname = "trios";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "wispborne";
    repo = "TriOS";
    rev = "main";
    hash = "sha256-eNl5+6boOrfS9tDjIXMK4NA6WCNtUXJ/f03g9wM+uLw=";
  };

in
  flutter.buildFlutterApplication rec {
    inherit pname version src;

    autoPubspecLock = "${src}/pubspec.lock";
    
    gitHashes = {
      "open_filex" = "sha256-U6h3yAw0L7ZoQdviAz9YRuHBy9TwGVLQiRTH+Hl9R0g=";
      "window_size" = "sha256-Y113BPSxlNnera/3Dq2BYAX1YiGbCrVgJsfClnLNhjk=";
    };

    vendorHash = "";

    nativeBuildInputs = with pkgs; [ copyDesktopItems pkg-config ];
    buildInputs = with pkgs; [ openssl zlib jre ];

    preConfigure = ''
      export C_INCLUDE_PATH=${pkgs.zlib.dev}/include:$C_INCLUDE_PATH
      export CXX_INCLUDE_PATH=${pkgs.zlib.dev}/include:$CXX_INCLUDE_PATH
      export LIBRARY_PATH=${pkgs.zlib}/lib:$LIBRARY_PATH
      
      # Some CMake versions also look here
      export CMAKE_PREFIX_PATH=${pkgs.zlib.dev}:${pkgs.zlib}:$CMAKE_PREFIX_PATH
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

  }