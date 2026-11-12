{
  self,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.default
    ./hardware.nix
    ./disko.nix
    ./configuration.nix
    self.nixosModules.base
    self.nixosModules.ssh
  ];
}
