{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.server;
in
{
  options = {
    my.server = { enable = mkEnableOption "Enable server configurations."; };
  };

  config = mkIf cfg.enable {
    my.common.enable = true;

    # Limit number of entries in boot menu.
    boot.loader.grub.configurationLimit = mkDefault 10;
    boot.loader.systemd-boot.configurationLimit = mkDefault 10;

    # This will cause too many packages to be built.
    # environment.noXlibs = true;

    networking.firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
      extraCommands = ''
        iptables -w -A OUTPUT -p tcp -m tcp --dport 25 -j REJECT
        ip6tables -w -A OUTPUT -p tcp -m tcp --dport 25 -j REJECT
      '';
      extraStopCommands = ''
        iptables -w -D OUTPUT -p tcp -m tcp --dport 25 -j REJECT
        ip6tables -w -D OUTPUT -p tcp -m tcp --dport 25 -j REJECT
      '';
    };
  };
}
