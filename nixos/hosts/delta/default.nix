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
    ./services.nix
    self.nixosModules.base
    self.nixosModules.ssh
    self.nixosModules.fail2ban
  ];
}
