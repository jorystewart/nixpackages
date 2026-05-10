{ pkgs? import <nixpkgs> {} }:

let
  inherit (pkgs) lib fetchFromGitHub makeDesktopItem makeWrapper copyDesktopItems libpulseaudio xdotool kdotool libnotify maven jre;

  runtimeLibs = with pkgs; [
    libxxf86vm
    glib
    gtk3
    pango
    atk
    cairo
    gdk-pixbuf
    libx11
    libxext
    libxrender
    libxtst
    libGL
    libusb1
  ];

  pname = "pcpanel";
  version = "1.8-SNAPSHOT";

  src = fetchFromGitHub {
    owner = "nvdweem";
    repo = "PCPanel";
    rev = "main";
    hash = "sha256-95ssfzUL2aO6F59Eoo1qBE/xkMHsQ30c4Op9+cgDr9o=";
  }; 

in
  maven.buildMavenPackage rec {
    inherit pname version src;

    # Maven stuff
    mvnHash = "";

    nativeBuildInputs = [ makeWrapper copyDesktopItems ];

    buildInputs = [ jre xdotool kdotool libpulseaudio ];

    installPhase = ''
      mkdir -p $out/share/pcpanel $out/bin
    
      # Copy the generated JAR (adjust path based on maven output)
      cp target/PCPanel-*.jar $out/share/pcpanel/PCPanel.jar

      # Create a wrapper to include runtime dependencies
      makeWrapper ${jre}/bin/java $out/bin/pcpanel \
        --add-flags "-jar $out/share/pcpanel/PCPanel.jar" \
        --prefix PATH : ${lib.makeBinPath [ xdotool kdotool ]} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libpulseaudio ]}
  '';

    desktopItems = [
      (makeDesktopItem {
        name = "pcpanel";
        exec = "pcpanel";
        icon = "pcpanel";
        comment = "PCPanel Configuration Tool";
        desktopName = "PCPanel";
        categories = [ "Settings" "HardwareSettings" ];
      })
    ];

    meta = with lib; {
      description = "Third party controller software for PCPanel devices";
      homepage = "https://github.com/nvdweem/PCPanel";
      mainProgram = "pcpanel";
    };
    
  }