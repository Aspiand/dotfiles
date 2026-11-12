{
  self,
  inputs,
  ...
}:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./gnome.nix

    inputs.grub2-themes.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager

    self.nixosModules.base
    self.nixosModules.desktop
    self.nixosModules.ssh
    self.nixosModules.node-exporter
    self.nixosModules.github-token
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs self; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.ao = ./home.nix;
    backupFileExtension = "bak";
  };
}
