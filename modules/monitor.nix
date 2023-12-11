{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.monitor;
in
{
  options = {
    my.monitor = {
      server = {
        enable = mkEnableOption "Enable monitor server.";
      };
      client = {
        enable = mkEnableOption "Enable monitor client.";
      };
    };
  };

  config = {
    services.nginx = mkIf cfg.server.enable {
      virtualHosts.localhost.locations = {
        "/grafana/" = {
          proxyPass =
            "http://localhost:${toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
        };
      };
    };

    services.grafana = {
      enable = cfg.server.enable;
      settings = {
        analytics.reporting_enabled = false;

        server = {
          http_addr = "::1";
          http_port = 9300;
          root_url = "%(protocol)s://%(domain)s/grafana/";
          serve_from_sub_path = true;
        };

        smtp = {
          enable = true;
          host = "localhost:25";
          user = "bot";
          password = "";
          fromAddress = "${config.networking.hostName}+grafana@xqzp.net";
        };
      };

      provision = {
        enable = true;
        datasources.settings = {
          datasources = [{
            name = "prometheus";
            type = "prometheus";
            url = "http://localhost:${toString config.services.prometheus.port}";
            isDefault = true;
          }];
        };
      };
    };

    services.prometheus = {
      enable = cfg.server.enable;
      retentionTime = "30d";

      scrapeConfigs = [
        {
          job_name = "node";
          scrape_interval = "30s";
          static_configs = [{
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
      ];

      exporters = {
        node = {
          enable = cfg.server.enable || cfg.client.enable;
          enabledCollectors = [
            "processes"
          ] ++ optionals (!config.boot.isContainer) [
            "interrupts"
            "logind"
            "systemd"
          ];
          port = 9100;
        };
      };
    };
  };
}
