{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.monitor;
in
{
  options = {
    my.monitor = {
      enable = mkEnableOption "Enable monitor server and client.";
      server = {
        enable = mkEnableOption "Enable monitor server.";
        influxdb-url-prefix = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Nginx proxy prefix for InfluxDB.";
        };
      };
      client = {
        enable = mkEnableOption "Enable monitor client.";
        outputs.influxdb-url = mkOption {
          type = types.str;
          default = "http://localhost:8086";
          description = "InfluxDB URL.";
        };
      };
    };
  };

  config = {
    my.monitor.server.enable = mkIf cfg.enable true;
    my.monitor.client.enable = mkIf cfg.enable true;

    environment.systemPackages = with pkgs; mkIf cfg.server.enable [
      config.services.influxdb.package
    ];

    services.grafana = mkIf cfg.server.enable {
      enable = true;
      port = 8300;
      domain = "localhost";
      protocol = "http";
      rootUrl = "%(protocol)s://%(domain)s/grafana/";
      extraOptions = { SERVER_SERVE_FROM_SUB_PATH = "true"; };

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
        fromAddress = "${config.networking.hostName}+grafana@xqzp.net";
      };
    };

    # services.prometheus = mkIf cfg.server.enable {
    #   enable = true;
    # };

    services.influxdb = mkIf cfg.server.enable {
      enable = true;
      extraConfig = { reporting-disabled = true; };
    };

    services.nginx = mkIf cfg.server.enable {
      enable = true;
      virtualHosts.localhost.locations = {
        "/grafana/" = {
          proxyPass =
            "http://127.0.0.1:${toString config.services.grafana.port}";
        };
      } // optionalAttrs (!isNull cfg.server.influxdb-url-prefix) {
        "${cfg.influxdb-url-prefix}" = {
          extraConfig = ''
            proxy_pass http://127.0.0.1:8086/;
          '';
        };
      };
    };

    services.telegraf = mkIf cfg.client.enable {
      enable = true;
      extraConfig = {
        agent = {
          interval = "30s";
          collection_jitter = "1s";
          flush_interval = "60s";
          flush_jitter = "10s";
        };
        outputs = {
          influxdb = {
            urls = [ cfg.client.outputs.influxdb-url ];
            database = "telegraf";
            timeout = "30s";
            content_encoding = "gzip";
          };
        };
        inputs = {
          conntrack = { };
          cpu = { };
          disk = { };
          diskio = { };
          internal = { };
          interrupts = { };
          kernel = { };
          linux_sysctl_fs = { };
          mem = { };
          net = { };
          netstat = { };
          nstat = { };
          processes = { };
          swap = { };
          system = { };

          # nginx = { urls = [ "http://localhost/nginx_status" ]; };
          # http_response = { urls = [ "http://localhost/" ]; };
          # ping = { urls = [ "9.9.9.9" ]; };
        } // optionalAttrs (cfg.server.enable) { influxdb = { }; }
        // optionalAttrs (config.my.desktop.enable) {
          sensors = { };
          smart = {
            path = "${
                  pkgs.writeShellScriptBin "smartctl"
                  "/run/wrappers/bin/sudo ${pkgs.smartmontools}/bin/smartctl $@"
                }/bin/smartctl";
          };
          temp = { };
          wireless = { };
        };
      };
    };

    systemd.services.telegraf.path =
      mkIf (cfg.client.enable && config.my.desktop.enable) [ pkgs.lm_sensors ];
    security.sudo.extraRules =
      mkIf (cfg.client.enable && config.my.desktop.enable) [{
        commands = [{
          command = "${pkgs.smartmontools}/bin/smartctl";
          options = [ "NOPASSWD" ];
        }];
        users = [ "telegraf" ];
      }];
  };
}
