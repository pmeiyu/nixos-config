{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.virtualization;
in
{
  options = {
    my.virtualization.enable = mkEnableOption "Enable virtualization.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ qemu virt-manager ];

    my.dns.hosts = [
      "192.168.122.1 host.lan"
    ];

    networking.firewall = {
      interfaces."virbr0".allowedUDPPorts = [
        53
        4010 # Scream
      ];
    };

    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
