{ pkgs? import <nixpkgs> {} }:

let
  inherit (pkgs) fetchFromGitHub makeDesktopItem makeWrapper copyDesktopItems;

  pname = "randovania";
  version = "10.8.0";

  src = fetchFromGitHub {
    owner = "randovania";
    repo = "randovania";
    rev = "v${version}";
    hash = "sha256-3miAV+hCsbGOJatxS46wLiksM/msPpE/uAafyaDUflE=";
  };

  python = pkgs.python314;

  json-delta = python.pkgs.buildPythonPackage rec {
    pname = "json-delta";
    version = "2.0";

    src = python.pkgs.fetchPypi {
      pname = "json_delta";
      inherit version;
      hash = "sha256-RipzZy91J1F9hjkwu0Qu0ZhsNd+2lg4PscuEOT3uplI=";
    };

    # json-delta is an older package and doesn't use modern pyproject.toml hooks
    format = "setuptools";
    doCheck = false; 
  };

  randovania-scm-version-schema = python.pkgs.buildPythonPackage rec {
    pname = "randovania-scm-version-schema";
    version = "0.1.0";

    src = fetchFromGitHub {
      owner = "randovania";
      repo = "randovania-scm-version-schema";
      rev = "v0.3.3";
      hash = "sha256-8Dgs1mygvTAJiqqKXZ/6EOuqrM1pu9We77rmeLc/5EA=";
    };

    pyproject = true;
    nativeBuildInputs = [
      python.pkgs.setuptools
      python.pkgs.setuptools-scm
      python.pkgs.wheel
    ];

    dontCheckRuntimeDeps = true;

    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-warn 'setuptools_scm>=10' 'setuptools_scm>=9'
    '';

  };

  python-socketio-handler = python.pkgs.buildPythonPackage rec {
    pname = "python-socketio-handler";
    version = "1.0.1";

    src = python.pkgs.fetchPypi {
      pname = "socketio_handler";
      inherit version;
      hash = "";
    };

    format = "setuptools";
    doCheck = false;
  };



in
  python.pkgs.buildPythonApplication {
    inherit pname version src;

    pyproject = true;

    SETUPTOOLS_SCM_PRETEND_VERSION = version;

    nativeBuildInputs = [
      makeWrapper
      copyDesktopItems
      python.pkgs.cython
      python.pkgs.poetry-core
      python.pkgs.dulwich
      python.pkgs.setuptools-scm
      randovania-scm-version-schema
    ];

    propagatedBuildInputs = with python.pkgs; [
      attrs
      click
      frozendict
      jsonschema
      networkx
      pillow
      pyqt6
      pyyaml
      requests
      setuptools
      tqdm
      zstandard
      dulwich
      construct
      python-slugify
      bitstruct
      cryptography
      tenacity
      rustworkx
      aiohttp
      aiofiles
      sentry-sdk
      python-socketio-handler
      json-delta
      cython
      uvicorn
      fastapi
      peewee
      prometheus-client
      prometheus-fastapi-instrumentator
      itsdangerous
      packaging
      aiocache
      cachetools
    ];

    preBuild = ''
      mkdir -p randovania
      cat <<EOF > randovania/version_hash.py
      VERSION = "${version}"
      VERSION_HASH = "${version}"
      dirty = False
      git_hash = b"${version}"
      EOF

      cp -r ${src}/components/socketio_handler .
    '';

    postInstall = ''
      mkdir -p $out/tools
      cp -r ${src}/tools/* $out/tools/
    '';

    pythonImportsCheck = [ "randovania" ];

    desktopItems = [
      (makeDesktopItem {
        name = "randovania";
        exec = "randovania";
        icon = "randovania";
        comment = "Randomizer platform for various games";
        desktopName = "Randovania";
        categories = [ "Game" ];
      })
    ];

    meta = {
      description = "Randomizer platform for various games";
      homepage = "https://github.com/randovania/randovania";
      mainProgram = "randovania";
    };
    
  }
