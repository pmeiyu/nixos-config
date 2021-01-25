{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.overlay-networks;
in
{
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
      settings = {
        Socks5Proxy = "localhost:1080";
      };
    };
  };
}
