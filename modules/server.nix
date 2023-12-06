{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.server;
in
{
  options = {
    my.server.enable = mkEnableOption "Enable server configurations.";
  };

  config = mkIf cfg.enable {
    my.common.enable = true;
    my.emacs.enable = true;
    my.emacs.package = mkDefault pkgs.emacs-nox;

    # Limit number of entries in boot menu.
    boot.loader.grub.configurationLimit = mkDefault 10;
    boot.loader.systemd-boot.configurationLimit = mkDefault 10;

    boot.loader.grub.efiInstallAsRemovable = true;

    # This will cause too many packages to be built.
    # environment.noXlibs = true;

    networking.firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
    };
  };
}
