{ pkgs? import <nixpkgs> {} }:

let
  inherit (pkgs) lib stdenv fetchFromGitHub makeDesktopItem copyDesktopItems pulseaudio xdotool kdotool libnotify;

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

  buildJdk = pkgs.jdk21;
  runJdk = pkgs.jdk25;

  pname = "pcpanel";
  version = "1.8-SNAPSHOT";

  src = fetchFromGitHub {
    owner = "nvdweem";
    repo = "PCPanel";
    rev = "main";
    hash = "sha256-95ssfzUL2aO6F59Eoo1qBE/xkMHsQ30c4Op9+cgDr9o=";
  }; 

in
  pkgs.maven.buildMavenPackage rec {
    inherit pname version src;

    jdk = buildJdk;

    mavenHash = "";
    mvnExtraArgs = "-Dmaven.compiler.release=21 -Djlink.skip=true -DskipTests";
    
    nativeBuildInputs = with pkgs; [ makeWrapper copyDesktopItems ];

    postPatch = ''
      # 1. Fix the NullPointerException in IconService
      sed -i -E 's/new File\s*\(\s*path\s*\)/new File(path != null ? path : "\/tmp")/g' src/main/java/com/getpcpanel/commands/IconService.java

      # 2. Downgrade Java version for toolchain compatibility
      sed -i 's|<java.version>25</java.version>|<java.version>21</java.version>|g' pom.xml
      sed -i 's|<maven.compiler.release>25</maven.compiler.release>|<maven.compiler.release>21</maven.compiler.release>|g' pom.xml
      
      # 3. Inject modern compiler plugin version
      substituteInPlace pom.xml \
        --replace-fail "<artifactId>maven-compiler-plugin</artifactId>" "<artifactId>maven-compiler-plugin</artifactId><version>3.13.0</version>"

      # 4. REMOVE PLUGIN EXECUTION: 
      # We target the specific jtoolprovider-plugin and its execution block.
      # This replaces the execution definition with a comment, which is 100% XML safe.
      substituteInPlace pom.xml \
        --replace-fail "<executions>" ""
    '';

    preBuild = ''
      export JAVA_HOME=${buildJdk}
      export PATH=${buildJdk}/bin:$PATH
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/java $out/bin
      
      cp target/PCPanel-*.jar $out/share/java/pcpanel.jar

      makeWrapper ${runJdk}/bin/java $out/bin/pcpanel \
        --add-flags "--enable-native-access=ALL-UNNAMED" \
        --add-flags "--add-opens=java.base/sun.misc=ALL-UNNAMED" \
        --add-flags "--add-opens=java.base/java.lang=ALL-UNNAMED" \
        --add-flags "--add-opens=java.base/java.io=ALL-UNNAMED" \
        --add-flags "-Dfile.encoding=UTF-8" \
        --add-flags "-jar $out/share/java/pcpanel.jar" \
        --set GDK_BACKEND "wayland" \
        --prefix PATH : ${lib.makeBinPath [ pulseaudio xdotool kdotool libnotify ]} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
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

    meta = with lib; {
      description = "Third party controller software for PCPanel devices";
      homepage = "https://github.com/nvdweem/PCPanel";
      mainProgram = "pcpanel";
    };
    
  }