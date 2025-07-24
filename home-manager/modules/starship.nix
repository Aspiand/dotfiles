{ config, pkgs, lib, ... }:

with lib;

{
  programs.starship = {
    enable = config.programs.bash.enable;
    enableBashIntegration = true;
    enableFishIntegration = mkDefault true;
    settings = {
      add_newline = false;
      character.error_symbol = "[✗](bold red)";

      cmd_duration = {
        min_time = 1000;
        format = "[$duration ](bold yellow)";
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };

      memory_usage = {
        disabled = false;
        threshold = 80;
        symbol = "󰍛 ";
      };

      nix_shell = {
        disabled = false;
        symbol = "󰼪 ";
        impure_msg = "[impure](bold red)";
        pure_msg = "[pure](bold green)";
        unknown_msg = "[unknown](bold yellow)";
        # format = "❄️ [$state( \($name\))](bold blue)";
      };

      sudo = {
        disabled = false;
        format = "[ɫ ](bold red)";
      };

      bun.disabled = true;
      buf.disabled = true;
      c.disabled = true;
      cpp.disabled = true;
      cmake.disabled = true;
      conda.disabled = true;
      crystal.disabled = true;
      daml.disabled = true;
      dart.disabled = true;
      deno.disabled = true;
      dotnet.disabled = true;
      elixir.disabled = true;
      elm.disabled = true;
      erlang.disabled = true;
      fennel.disabled = true;
      gcloud.disabled = true;
      gleam.disabled = true;
      golang.disabled = true;
      guix_shell.disabled = true;
      gradle.disabled = true;
      haskell.disabled = true;
      haxe.disabled = true;
      helm.disabled = true;
      java.disabled = true;
      julia.disabled = true;
      kotlin.disabled = true;
      lua.disabled = true;
      meson.disabled = true;
      mise.disabled = true;
      mojo.disabled = true;
      nats.disabled = true;
      nim.disabled = true;
      nodejs.disabled = true;
      ocaml.disabled = true;
      odin.disabled = true;
      opa.disabled = true;
      openstack.disabled = true;
      perl.disabled = true;
      php.disabled = true;
      pixi.disabled = true;
      pulumi.disabled = true;
      purescript.disabled = true;
      python.disabled = true;
      quarto.disabled = true;
      rlang.disabled = true;
      raku.disabled = true;
      red.disabled = true;
      ruby.disabled = true;
      rust.disabled = true;
      scala.disabled = true;
      solidity.disabled = true;
      spack.disabled = true;
      swift.disabled = true;
      terraform.disabled = true;
      typst.disabled = true;
      vagrant.disabled = true;
      vlang.disabled = true;
      zig.disabled = true;
    };
  };
}