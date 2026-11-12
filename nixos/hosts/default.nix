# mkHost — one NixOS system per host, all built from this flake.
#
# `inputs` is the host's own slice of the root flake's inputs. A host cannot
# reference an input it was not handed: the name simply is not in scope, so
# evaluation fails loudly instead of silently borrowing another host's input.
#
# `nixpkgs` is chosen per host so channels do not have to match. It is a
# whole-eval choice — lib, the NixOS module set and pkgs all come from the same
# nixpkgs. Do NOT reach for `nixpkgs.pkgs = import <other-nixpkgs> {}` instead:
# that mixes modules from one nixpkgs with packages from another and breaks at
# eval time.
{ self }:
{
  modules,
  system ? "x86_64-linux",
  nixpkgs ? self.inputs.nixpkgs,
  inputs ? { },
  extraSpecialArgs ? { },
}:
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit self inputs;
  }
  // extraSpecialArgs;

  modules = [
    {
      nixpkgs.overlays = [ self.overlays.default ];
      system.nixos.revision = nixpkgs.lib.mkDefault (self.rev or self.dirtyRev or "Unknown");
    }
    # Custom module definitions (nix/modules/*) — all available, the host still
    # has to `services.<name>.enable = true` itself.
    { imports = self.modules.imports; }
  ]
  ++ modules;
}
