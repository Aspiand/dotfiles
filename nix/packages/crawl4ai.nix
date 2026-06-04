{ pkgs, ... }:

let
  crawl4ai = pkgs.python3Packages.buildPythonPackage rec {
    pname = "crawl4ai";
    version = "0.6.2";
    format = "setuptools";

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-9SrO5TlQDsX8jtu306M3ihsm95AXpSEXvRBnOpCg9WI=";
    };

    nativeBuildInputs = with pkgs.python3Packages; [
      setuptools
    ];

    propagatedBuildInputs = with pkgs.python3Packages; [
      httpx
      beautifulsoup4
      lxml
      aiohttp
      aiofiles
      markdownify
      colorama
      pyopenssl
      pydantic
    ];

    doCheck = false;

    preBuild = ''
      export HOME="$TMPDIR"
    '';
  };
in
crawl4ai
