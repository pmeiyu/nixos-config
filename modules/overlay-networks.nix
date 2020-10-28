{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.overlay-networks;
in {
  options = {
    my.overlay-networks.enable = mkEnableOption "Enable overlay networks";
  };

  config = mkIf cfg.enable {
    services.i2pd = {
      enable = true;
      enableIPv6 = true;
      proto.http.enable = true;
      proto.httpProxy.enable = true;
      proto.socksProxy.enable = true;
      inTunnels = {
        ssh = {
          address = "::1";
          port = 22;
          destination = "redundant placeholder for nix";
        };
        http = {
          address = "::1";
          port = 80;
          destination = "redundant placeholder for nix";
        };
      };
    };

    services.tor = {
      enable = true;
      client.enable = true;
      client.transparentProxy.enable = true;
      extraConfig = ''
        Socks5Proxy localhost:1080
      '';
    };

    systemd.services.v2ray = {
      description = "v2ray";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.v2ray}/bin/v2ray -config /etc/v2ray/config.json";
        DynamicUser = true;
      };
    };
  };
}
