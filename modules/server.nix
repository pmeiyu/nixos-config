{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.server;
in {
  options = {
    my.server = { enable = mkEnableOption "Enable server configurations."; };
  };

  config = mkIf cfg.enable {
    my.common.enable = true;

    # Limit number of entries in boot menu.
    boot.loader.grub.configurationLimit = mkDefault 2;
    boot.loader.systemd-boot.configurationLimit = mkDefault 2;

    environment.noXlibs = true;

    networking.firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
      extraCommands = ''
        iptables -A OUTPUT -p tcp -m tcp --dport 25 -j REJECT
        ip6tables -A OUTPUT -p tcp -m tcp --dport 25 -j REJECT
      '';
      extraStopCommands = ''
        iptables -D OUTPUT -p tcp -m tcp --dport 25 -j REJECT
        ip6tables -D OUTPUT -p tcp -m tcp --dport 25 -j REJECT
      '';
    };
  };
}
