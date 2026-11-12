{
  self,
  inputs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    inputs.copyparty.nixosModules.default
    inputs.hermes-agent.nixosModules.default

    ./hardware.nix
    ./disko.nix
    ./configuration.nix
    ./secrets.nix
    ./services.nix
    ./hermes.nix

    self.nixosModules.base
    self.nixosModules.ssh
    self.nixosModules.headroom
    self.nixosModules.hindsight
    self.nixosModules.searxng
    self.nixosModules.grafana
    self.nixosModules.victoriametrics
    self.nixosModules.victorialogs
    self.nixosModules.node-exporter
    self.nixosModules.process-exporter
  ];
}
