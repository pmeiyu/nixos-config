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

    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
