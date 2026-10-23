/*
	TODO: remove later after fixed
*/

{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.codegraph = pkgs.codegraph.overrideAttrs (old: {
        # symlink, not a copy: the wrapper execs $out/lib/codegraph/node
        postFixup = (old.postFixup or "") + ''
          ln -sf ${pkgs.nodejs}/bin/node $out/lib/codegraph/node
        '';
      });
    };
}
