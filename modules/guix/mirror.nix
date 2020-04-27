{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.guix.mirror;
in {
  options = {
    services.guix.mirror = {
      enable = mkEnableOption "Enable Guix mirror";
      set-as-substitute = mkOption {
        type = types.bool;
        default = true;
        description = "Set this mirror as a substitute server.";
      };
      domain = mkOption {
        type = types.str;
        default = "mirror.lan";
        description = "Domain name.";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.extraHosts = ''
      ::1       ${cfg.domain}
      127.0.0.1 ${cfg.domain}
    '';

    services.nginx = {
      enable = true;
      proxyResolveWhileRunning = true;
      commonHttpConfig = ''
        # cache for guix mirror files
        proxy_cache_path /srv/cache/guix
                levels=2
                inactive=60d             # inactive keys removed after 60d
                keys_zone=guix-cache:8m  # meta data: ~64K keys
                max_size=50g;            # total cache data size max
      '';
      upstreams = {
        guix-upstream = {
          servers = { "guix-mirror.pengmeiyu.com:443" = { }; };
        };
      };

      virtualHosts."${cfg.domain}" = {
        locations."/guix/" = {
          extraConfig = ''
            proxy_pass https://guix-upstream/;
            proxy_ssl_server_name on;
            proxy_ssl_name guix-mirror.pengmeiyu.com;
            proxy_set_header Host guix-mirror.pengmeiyu.com;

            proxy_cache guix-cache;
            proxy_cache_valid 200 30d;
            proxy_cache_valid any 3m;
            proxy_ignore_client_abort on;

            client_body_buffer_size 256k;
            proxy_connect_timeout 60s;

            proxy_hide_header    Set-Cookie;
            proxy_ignore_headers Set-Cookie;

            gzip off;
          '';
        };
        extraConfig = ''
          access_log  /var/log/nginx/${cfg.domain}.access.log;
          error_log  /var/log/nginx/${cfg.domain}.error.log;
        '';
      };
    };
    system.activationScripts.my-nginx = ''
      mkdir -p /srv/cache/guix && chown -R nginx:nginx /srv/cache/guix
    '';
  };
}
