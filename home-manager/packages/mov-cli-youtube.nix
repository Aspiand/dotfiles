{
  lib,
  buildPythonPackage,
  fetchPypi,

  # dependencies
  pytubefix,
  requests,
  setuptools,
  yt-dlp
}:

buildPythonPackage rec {
  pname = "mov_cli_youtube";
  version = "1.3.8";
  pyproject = true;
  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-qy/s7teIKuqecrkSURuc+oaFRX4u3J2ZuZSkLD+nXyk=";
  };

  postPatch = ''
    rm -f $out/bin/pydoc
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
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