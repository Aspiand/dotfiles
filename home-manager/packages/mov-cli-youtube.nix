{
  lib,
  fetchFromGitHub,
  python3
}:

let
  pname = "mov-cli-youtube";
  version = "1.3.8";
in

python3.pkgs.buildPythonPackage {
  inherit pname version;
  pyproject = true;
  src = fetchFromGitHub {
    owner = "mov-cli";
    repo = pname;
    tag = version;
    hash = "sha256-2dc6EYy+6vCOCy+FZBVKWzeV3xFAswUaX9XfYk0jz1E=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    pytubefix
    requests
    setuptools
    yt-dlp
  ];

  meta = with lib; {
    homepage = "https://github.com/mov-cli/mov-cli-youtube";
    description = "A mov-cli v4 plugin for watching youtube.";
    license = licenses.mit;
    maintainers = with maintainers; [ goldy ];
  };
}