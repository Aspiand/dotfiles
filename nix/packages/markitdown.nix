{ lib, ... }:

let
  mkMarkitdown =
    pkgs:
    let
      pname = "markitdown";
      version = "0.1.6";
    in
    pkgs.python312Packages.buildPythonApplication {
      inherit pname version;
      format = "pyproject";

      src = pkgs.fetchPypi {
        inherit pname version;
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      };

      # Core + practical optional dependencies
      propagatedBuildInputs = with pkgs.python312Packages; [
        # Core
        beautifulsoup4
        requests
        markdownify
        magika
        charset-normalizer
        defusedxml

        # PDF
        pdfminer-six
        pdfplumber

        # Office
        python-pptx
        mammoth
        pandas
        openpyxl
        xlrd
        lxml

        # Outlook
        olefile

        # Audio
        pydub
        speechrecognition

        # YouTube
        youtube-transcript-api
      ];

      nativeBuildInputs = with pkgs.python312Packages; [
        setuptools
        wheel
      ];

      # Skip tests — complex dependency tree
      doCheck = false;

      meta = with pkgs.lib; {
        description = "Convert files and office documents to Markdown";
        homepage = "https://github.com/microsoft/markitdown";
        license = licenses.mit;
        mainProgram = "markitdown";
        platforms = platforms.linux ++ platforms.darwin;
      };
    };
in
{
  flake.overlays.markitdown = final: _: {
    markitdown = mkMarkitdown final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.markitdown = mkMarkitdown pkgs;
    };
}
