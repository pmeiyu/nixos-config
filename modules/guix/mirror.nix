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
      upstream = mkOption {
        type = types.str;
        default = "ci.guix.gnu.org";
        description = "Upstream substitute server.";
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
        # cache for guix mirror
        proxy_cache_path /srv/cache/guix-mirror
            levels=2
            inactive=30d              # remove inactive keys after this period
            keys_zone=guix-mirror:8m  # about 8 thousand keys per megabyte
            max_size=50g;             # total cache data size
      '';

      virtualHosts."${cfg.domain}" = {
        locations."/guix/" = {
          extraConfig = ''
            proxy_pass https://${cfg.upstream}/;
            proxy_ssl_server_name on;
            proxy_ssl_name ${cfg.upstream};
            proxy_set_header Host ${cfg.upstream};

            proxy_cache guix-mirror;
            proxy_cache_valid 200 60d;
            proxy_cache_valid any 3m;
            proxy_connect_timeout 60s;
            proxy_ignore_client_abort on;

            client_body_buffer_size 256k;

            proxy_hide_header Set-Cookie;
            proxy_ignore_headers Set-Cookie;

            gzip off;
          '';
        };
        extraConfig = ''
          access_log /var/log/nginx/${cfg.domain}.access.log;
          error_log /var/log/nginx/${cfg.domain}.error.log;
        '';
      };
    };
    system.activationScripts.my-nginx = ''
      mkdir -p /srv/cache/guix-mirror && \
      chown nginx:nginx /srv/cache/guix-mirror
    '';
  };
}
