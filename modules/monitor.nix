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
      };
      client = {
        enable = mkEnableOption "Enable monitor client.";
        outputs.influxdb.url = mkOption {
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

    environment.systemPackages = mkIf cfg.server.enable [
      pkgs.influxdb2-cli
    ];

    services.grafana = mkIf cfg.server.enable {
      enable = true;
      settings = {
        analytics.reporting_enabled = false;

        server = {
          http_addr = "localhost";
          http_port = 8300;
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
            name = "influxdb";
            type = "influxdb";
            url = "http://localhost:8086";
            database = "telegraf";
            isDefault = true;
          }];
        };
      };
    };

    # services.prometheus = mkIf cfg.server.enable {
    #   enable = true;
    # };

    services.influxdb2 = mkIf cfg.server.enable {
      enable = true;
      settings = {
        reporting-disabled = true;
      };
    };

    services.nginx = mkIf cfg.server.enable {
      virtualHosts.localhost.locations = {
        "/grafana/" = {
          proxyPass =
            "http://localhost:${toString config.services.grafana.settings.server.http_port}";
        };
        "/influxdb/" = {
          extraConfig = ''
            proxy_pass http://localhost:8086/;
          '';
        };
      };
    };

    services.telegraf = mkIf cfg.client.enable {
      enable = true;
      environmentFiles = [ "/etc/secrets/telegraf" ];
      extraConfig = {
        agent = {
          interval = "30s";
          collection_jitter = "2s";
          flush_interval = "60s";
          flush_jitter = "10s";
        };
        outputs = {
          influxdb_v2 = {
            urls = [ cfg.client.outputs.influxdb.url ];
            token = "$INFLUX_TOKEN";
            organization = "default";
            bucket = "telegraf";
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
        } // optionalAttrs (config.my.desktop.enable) {
          sensors = { };
          smart = {
            path_nvme = "${pkgs.nvme-cli}/bin/nvme";
            path_smartctl = "${pkgs.smartmontools}/bin/smartctl";
            use_sudo = true;
          };
          temp = { };
          wireless = { };
        };
      };
    };

    systemd.services.telegraf.path =
      mkIf (cfg.client.enable && config.my.desktop.enable) [
        # sudo
        "/run/wrappers"

        pkgs.lm_sensors
      ];
    security.sudo.extraRules =
      mkIf (cfg.client.enable && config.my.desktop.enable) [{
        commands = [
          {
            command = "${pkgs.nvme-cli}/bin/nvme";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.smartmontools}/bin/smartctl";
            options = [ "NOPASSWD" ];
          }
        ];
        users = [ "telegraf" ];
      }];
  };
}
