{ ... }:

let
  # Select wheel based on Python interpreter and system
  wheelSources = {
    "cp310-x86_64-linux" = {
      url = "https://files.pythonhosted.org/packages/e5/a4/c6e454f6ddb06b8dd8ea1d8f5f5609a5f36d72c6e1bb99749109710a3fa1/headroom_ai-0.24.0-cp310-cp310-manylinux_2_28_x86_64.whl";
      hash = "sha256-FPla38pfu3kJk7kZy1ukmZhii/2Q0+2DMDsVzL+JUjs=";
    };
    "cp310-aarch64-linux" = {
      url = "https://files.pythonhosted.org/packages/6e/6f/3e193e6eec1a95619d2323143e2cd3eb133d1371539d561177958954b68f/headroom_ai-0.24.0-cp310-cp310-manylinux_2_28_aarch64.whl";
      hash = "sha256-4jlPfpskKTGUsEGqMFDpuGrMB5SXdvz70//2Rt/2Sgs=";
    };
    "cp311-x86_64-linux" = {
      url = "https://files.pythonhosted.org/packages/eb/32/7abc8f4533dc9a6b015df310fe7a3b7405e270ebe3a8257c967f02757734/headroom_ai-0.24.0-cp311-cp311-manylinux_2_28_x86_64.whl";
      hash = "sha256-El9cDT92lYzjiXns187pjhVPym/DrXiUHK7jyz/84wk=";
    };
    "cp311-aarch64-linux" = {
      url = "https://files.pythonhosted.org/packages/fd/ba/cac2d703b0f47add03b5a5beaa53f8eec6b9fda08a46154ae41168de4178/headroom_ai-0.24.0-cp311-cp311-manylinux_2_28_aarch64.whl";
      hash = "sha256-mVaUx5RqaarRr6l/CGxaY6PYpgc0+g3UhXYeG9s5ZrI=";
    };
    "cp312-x86_64-linux" = {
      url = "https://files.pythonhosted.org/packages/ed/85/4a7a1c3f215b43449725583a95b7261065b808d166532549da643ed1550b/headroom_ai-0.24.0-cp312-cp312-manylinux_2_28_x86_64.whl";
      hash = "sha256-zqW1Hpl9bSlefCy+Z5jLRgFnVfX9DSjvc65MS5R3IWE=";
    };
    "cp312-aarch64-linux" = {
      url = "https://files.pythonhosted.org/packages/7a/67/25fd8ea4d720c1ccecb5cbc227ee06023a10d222ff6add4ebdaf7349be89/headroom_ai-0.24.0-cp312-cp312-manylinux_2_28_aarch64.whl";
      hash = "sha256-zEf1SKVJ1Lrvte2p920zc+xlQFu3kAXXBafFKgjL/EQ=";
    };
    "cp313-x86_64-linux" = {
      url = "https://files.pythonhosted.org/packages/db/c7/cd1da4140fe3fed8f22cb4a76d1395f2ae4e56c692ed0b908e1b453a7a45/headroom_ai-0.24.0-cp313-cp313-manylinux_2_28_x86_64.whl";
      hash = "sha256-P+VszWxW/v2tWm8ryKGIEY/lR0kjUlUEh/eg6PhpEu8=";
    };
    "cp313-aarch64-linux" = {
      url = "https://files.pythonhosted.org/packages/b2/d3/e4bd27b667085a26c52ae341715e367939b6325507994ef87c22394c4cfb/headroom_ai-0.24.0-cp313-cp313-manylinux_2_28_aarch64.whl";
      hash = "sha256-h5P/jpsnRrR/Cw4BF/xDdRvLjzLqHOi/II+QapniNCI=";
    };
  };

  mkHeadroom =
    pkgs:
    let
      pname = "headroom-ai";
      version = "0.24.0";
      python = pkgs.python313;
      pythonPackages = pkgs.python313Packages;

      # Python 3.13 chosen because pre-built cp313 wheels are available on PyPI
      # (cp314 not available — which is why the old source build failed)
      pythonTag = "cp313";

      archTag = if pkgs.stdenv.isLinux then
        (if pkgs.stdenv.hostPlatform.isAarch64 then "aarch64-linux" else "x86_64-linux")
      else
        throw "headroom-ai: only Linux is supported (no macOS wheels packaged here)";

      wheelKey = "${pythonTag}-${archTag}";
      wheelSrc = wheelSources.${wheelKey} or (throw "headroom-ai: no pre-built wheel for ${wheelKey}");

    in
    pythonPackages.buildPythonPackage {
      inherit pname version;
      format = "wheel";

      src = pkgs.fetchurl {
        inherit (wheelSrc) url hash;
      };

      # Wheel already contains compiled extension — no build phase needed
      dontBuild = true;

      # Runtime dependencies — matches requires_dist from PyPI metadata
      # Core deps only (no extras)
      propagatedBuildInputs = with pythonPackages; [
        tiktoken
        pydantic
        litellm
        click
        rich
        opentelemetry-api
        httpx
        fastapi
        uvicorn
        mcp
      ];

      # ast-grep binary needed in PATH at runtime
      # Package in nixpkgs is named `ast-grep`, not `ast-grep-cli`
      postInstall = ''
        wrapProgram $out/bin/headroom \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ast-grep ]}
      '';

      nativeBuildInputs = [ pkgs.makeWrapper ];

      # Wheel tested upstream — skip check
      doCheck = false;

      dontCheckRuntimeDeps = true;

      pythonImportsCheck = [ "headroom" ];

      meta = with pkgs.lib; {
        description = "Context optimization layer for LLM applications — 60-95% token reduction";
        homepage = "https://github.com/chopratejas/headroom";
        license = licenses.asl20;
        mainProgram = "headroom";
        platforms = platforms.linux;
      };
    };
in
{
  flake.overlays.headroom = final: _: {
    headroom = mkHeadroom final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.headroom = mkHeadroom pkgs;
    };
}
