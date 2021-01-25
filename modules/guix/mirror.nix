{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.guix.mirror;
  upstream-domain =
    elemAt (splitString "/" (elemAt (splitString ":" cfg.upstream) 1)) 2;
in
{
  options = {
    services.guix.mirror = {
      enable = mkEnableOption "Enable Guix mirror";
      domain = mkOption {
        type = types.str;
        default = "guix.mirror.lan";
        description = "Domain name.";
      };
      upstream = mkOption {
        type = types.strMatching "https?://.+";
        default = "https://ci.guix.gnu.org";
        description = "Upstream substitute server.";
      };
      apply-to-self = mkOption {
        type = types.bool;
        default = true;
        description =
          "Apply this mirror as a substitute server to the machine itself.";
      };
      cache-directory = mkOption {
        type = types.str;
        default = "/srv/cache/guix-mirror";
        description = "Cache directory for guix mirror.";
      };
      cache-max-size = mkOption {
        type = types.str;
        default = "100g";
        description = "Max storage size.";
      };
      cache-valid-time = mkOption {
        type = types.str;
        default = "365d";
        description = "Cache valid time.";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.extraHosts = ''
      ::1       ${cfg.domain}
      127.0.0.1 ${cfg.domain}
    '';

    services.guix.substitute-urls = [ "http://${cfg.domain}" ];

    services.nginx = {
      enable = true;
      proxyResolveWhileRunning = true;
      commonHttpConfig = ''
        # cache for guix mirror
        proxy_cache_path ${cfg.cache-directory}
            levels=2
            inactive=30d               # Remove inactive keys after this period.
            keys_zone=guix-mirror:10m  # About 8 thousand keys per megabyte.
            max_size=${cfg.cache-max-size};  # Total cache data size.
      '';

      virtualHosts."${cfg.domain}" = {
        locations."/" = {
          extraConfig = ''
            proxy_pass ${cfg.upstream};
            proxy_ssl_server_name on;
            proxy_ssl_name ${upstream-domain};
            proxy_set_header Host ${upstream-domain};

            proxy_cache guix-mirror;
            proxy_cache_valid 200 206 ${cfg.cache-valid-time};
            proxy_cache_valid any 1m;
            proxy_connect_timeout 10s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
            gzip off;

            proxy_ignore_client_abort on;
            proxy_hide_header Set-Cookie;
            proxy_ignore_headers Set-Cookie;
          '';
        };
        extraConfig = ''
          access_log /var/log/nginx/${cfg.domain}.access.log;
          error_log /var/log/nginx/${cfg.domain}.error.log;
        '';
      };
    };

    systemd.services.nginx.serviceConfig.ReadWritePaths = cfg.cache-directory;

    system.activationScripts.my-guix-mirror = ''
      mkdir -p ${cfg.cache-directory} && \
      chown nginx:nginx ${cfg.cache-directory}
    '';
  };
}
