{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.vlmcsd;
in {
  options = {
    services.vlmcsd = { enable = mkEnableOption "Enable vlmcsd."; };
  };

  config = mkIf cfg.enable {
    systemd.services.vlmcsd = {
      description = "vlmcsd server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.vlmcsd}/bin/vlmcsd -D -v";
        User = "nobody";
      };
    };

    networking.firewall.allowedTCPPorts = [ 1688 ];
  };
}
