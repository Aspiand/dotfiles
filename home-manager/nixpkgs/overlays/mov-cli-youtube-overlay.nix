self: super: let
  pname = "mov-cli-youtube";
  version = "1.3.8";
in {
  mov-cli-youtube = super.buildPythonPackage rec {
    inherit pname version;
    pyproject = true;

    src = super.fetchFromGitHub {
      owner = "mov-cli";
      repo = pname;
      tag = version;
      sha256 = "0aazlwzjr94lp6crvp1fgr2qb1pskhdm24mrfagflal8szpfqbxb";
    };

    propagatedBuildInputs = with super.python3.pkgs; [
      pytubefix
      requests
      yt-dlp
    ];

    meta = with super.lib; {
      homepage = "https://github.com/mov-cli/mov-cli-youtube";
      description = " A mov-cli v4 plugin for watching youtube.";
      license = licenses.mit;
      maintainers = with maintainers; [ goldy ];
    };
  };
}