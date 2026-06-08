{ pkgs? import <nixpkgs> {} }:

let
  inherit (pkgs) lib fetchFromGitHub makeDesktopItem makeWrapper copyDesktopItems libpulseaudio xdotool kdotool pulseaudio;

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

  jdkWithFx = pkgs.zulu25.override { enableJavaFX = true; };

in
  pkgs.maven.buildMavenPackage {
    inherit pname version src;

    # Maven stuff
    mvnHash = "sha256-WzplOXPwtoGjSiU0e7EXW0X67zorQOOV3rF3zCGHcBo=";
    mvnJdk = jdkWithFx;
    mvnFlags = "-DskipTests";

    patches = [ ./pom.xml.patch ./IconService.patch ./SndCtrlPulseAudio.java.patch ];

    nativeBuildInputs = [ makeWrapper copyDesktopItems ];

    buildInputs = [ jdkWithFx xdotool kdotool libpulseaudio ];

    env = {
      JAVA_HOME = "${jdkWithFx}";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mkdir -p $out/share/pcpanel
      mkdir -p $out/share/pcpanel/lib
    
      cp target/dependency/pcpanel-${version}.jar $out/share/pcpanel/pcpanel.jar

      if [ -d "target/dependency" ]; then
        cp target/dependency/*.jar $out/share/pcpanel/lib/
      fi

      makeWrapper ${jdkWithFx}/bin/java $out/bin/pcpanel \
        --add-flags "--enable-native-access=ALL-UNNAMED" \
        --add-flags "--add-opens=java.base/sun.misc=ALL-UNNAMED" \
        --add-flags "--add-opens=java.base/java.lang=ALL-UNNAMED" \
        --add-flags "--add-opens=java.base/java.io=ALL-UNNAMED" \
        --add-flags "--add-exports=javafx.controls/com.sun.javafx.scene.control.skin.resources=ALL-UNNAMED" \
        --add-flags "--add-exports=javafx.base/com.sun.javafx.event=ALL-UNNAMED" \
        --add-flags "-Dfile.encoding=UTF-8" \
        --add-flags "-cp $out/share/pcpanel/pcpanel.jar:$out/share/pcpanel/lib/*" \
        --add-flags "com.getpcpanel.Main" \
        --set GDK_BACKEND "wayland" \
        --prefix PATH : ${lib.makeBinPath [ xdotool kdotool pulseaudio ]} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (runtimeLibs ++ [ libpulseaudio ])}

        runHook postInstall
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

    meta = {
      description = "Third party controller software for PCPanel devices";
      homepage = "https://github.com/nvdweem/PCPanel";
      mainProgram = "pcpanel";
    };
    
  }
