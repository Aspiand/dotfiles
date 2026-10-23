{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      packages.mempalace = pkgs.python3Packages.buildPythonPackage rec {
        pname = "mempalace";
        version = "3.11.0";
        src = pkgs.fetchFromGitHub {
          owner = "mempalace";
          repo = "mempalace";
          rev = "v${version}";
          hash = "sha256-flBz0bAL3X6dSTNedyKXnKSSonrb1kJQpy0XtjNyq6I=";
        };
        pyproject = true;
        build-system = with pkgs.python3Packages; [ hatchling ];
        dependencies =
          with pkgs.python3Packages;
          [
            chromadb
            pyyaml
            huggingface-hub
            tokenizers
            numpy
            python-dateutil
          ]
          ++ pkgs.lib.optionals (pkgs.python3.pythonOlder "3.11") [ tomli ];
        nativeCheckInputs = with pkgs.python3Packages; [
          pytest
          pytest-cov
          pytest-rerunfailures
        ];
        pythonImportsCheck = [ "mempalace" ];
        meta = with pkgs.lib; {
          description = "Local-first AI memory system — mine conversations into a searchable palace";
          homepage = "https://github.com/mempalace/mempalace";
          license = licenses.mit;
          maintainers = [ ];
          mainProgram = "mempalace";
          platforms = platforms.linux ++ platforms.darwin;
        };
      };
    };
}
