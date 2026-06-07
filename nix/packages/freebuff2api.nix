{ ... }:

let
  mkFreebuff2api =
    pkgs:
    let
      pname = "freebuff2api";
      version = "0.1.0";
      rev = "a1c10357098f0615a8b605bf32ed9455e33320e4";
      go = pkgs.go_1_25 or pkgs.go;
    in
    pkgs.buildGoModule rec {
      inherit pname version;

      src = pkgs.fetchFromGitHub {
        owner = "Quorinex";
        repo = "Freebuff2API";
        inherit rev;
        hash = "sha256-oVCqWYI02S76Hm/1IunXu8XQAsAdbJoE4hF0TL25tr0=";
      };

      vendorHash = "sha256-mcvjEiKLtI9EJMgXtEcEHzdbYYnXVYRyVxSL2jHJGTo=";

      # Lock to a compatible Go toolchain; upstream requires go 1.23
      nativeBuildInputs = [ go ];

      meta = with pkgs.lib; {
        description = "OpenAI-compatible proxy server for Freebuff — free model access via any OpenAI client";
        homepage = "https://github.com/Quorinex/Freebuff2API";
        license = licenses.mit;
        mainProgram = "freebuff2api";
        platforms = platforms.linux;
      };
    };
in
{
  flake.overlays.freebuff2api = final: _: {
    freebuff2api = mkFreebuff2api final;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.freebuff2api = mkFreebuff2api pkgs;
    };
}
