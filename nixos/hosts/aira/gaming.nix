{ lib, ... }:

with lib;

{
  services."9router".enable = mkForce false;
  services.hermes-agent.enable = mkForce false;
  services.tailscale.enable = mkForce false;
  services.searx.enable = mkForce false;

  virtualisation.docker.enable = mkForce false;

  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
    "kernel.nmi_watchdog" = 0;
  };
}
