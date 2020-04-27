{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.monitor;
in {
  options = { my.monitor = { enable = mkEnableOption "Enable monitor."; }; };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;
      port = 8300;
      domain = "localhost";
      protocol = "http";
      provision = {
        enable = true;
        datasources = [{
          name = "influxdb";
          type = "influxdb";
          url = "http://localhost:8086";
          database = "telegraf";
          isDefault = true;
        }];
      };
      smtp = {
        enable = true;
        host = "localhost:25";
        user = "bot";
        password = "";
        fromAddress = "${config.networking.hostName}+grafana@pengmeiyu.com";
      };
    };

    # services.prometheus = {
    #   enable = true;
    # };

    services.influxdb.enable = true;

    services.telegraf = {
      enable = true;
      extraConfig = {
        outputs = {
          influxdb = {
            urls = [ "http://localhost:8086" ];
            database = "telegraf";
          };
        };
        inputs = {
          cpu = { };
          disk = { };
          diskio = { };
          kernel = { };
          mem = { };
          net = { };
          netstat = { };
          processes = { };
          swap = { };
          system = { };

          # nginx = { urls = [ "http://localhost/nginx_status" ]; };
          # http_response = { urls = [ "http://localhost/" ]; };
          # ping = { urls = [ "9.9.9.9" ]; };
        } // optionalAttrs (config.my.desktop.enable) {
          sensors = { };
          smart = { };
          temp = { };
          wireless = { };
        };
      };
    };
  };
}
