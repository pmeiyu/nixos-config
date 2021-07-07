{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.nginx;
in
{
  options = { my.nginx = { enable = mkEnableOption "Enable Nginx."; }; };

  config = mkIf cfg.enable {
    security.acme.acceptTerms = true;
    security.acme.email = "acme@xqzp.net";

    services.nginx = {
      enable = true;
      package = pkgs.openresty;
      additionalModules = with pkgs.nginxModules; [ ];

      virtualHosts.localhost = {
        default = mkDefault true;
        locations."/" = {
          root = "/srv/http/default";
          index = "index.html";
        };
        locations."/echo" = {
          extraConfig = ''
            echo -n $echo_client_request_headers;
            echo_request_body;
          '';
        };
        locations."/ip" = {
          extraConfig = ''
            default_type text/plain;
            return 200 "$remote_addr\n";
          '';
        };
        locations."/nginx_status" = {
          extraConfig = ''
            stub_status on;
            access_log off;
            allow ::1;
            allow 127.0.0.1;
            deny all;
          '';
        };
      };
      commonHttpConfig = "
        real_ip_header X-Forwarded-For;

        set_real_ip_from 127.0.0.1;
        set_real_ip_from ::1;

        # Cloudflare
        set_real_ip_from 103.21.244.0/22;
        set_real_ip_from 103.22.200.0/22;
        set_real_ip_from 103.31.4.0/22;
        set_real_ip_from 104.16.0.0/13;
        set_real_ip_from 104.24.0.0/14;
        set_real_ip_from 108.162.192.0/18;
        set_real_ip_from 131.0.72.0/22;
        set_real_ip_from 141.101.64.0/18;
        set_real_ip_from 162.158.0.0/15;
        set_real_ip_from 172.64.0.0/13;
        set_real_ip_from 173.245.48.0/20;
        set_real_ip_from 188.114.96.0/20;
        set_real_ip_from 190.93.240.0/20;
        set_real_ip_from 197.234.240.0/22;
        set_real_ip_from 198.41.128.0/17;
        set_real_ip_from 2400:cb00::/32;
        set_real_ip_from 2606:4700::/32;
        set_real_ip_from 2803:f800::/32;
        set_real_ip_from 2405:b500::/32;
        set_real_ip_from 2405:8100::/32;
        set_real_ip_from 2c0f:f248::/32;
        set_real_ip_from 2a06:98c0::/29;
      ";
    };

    system.activationScripts.my-nginx = ''
      mkdir -p /var/log/nginx && chown -R nginx:nginx /var/log/nginx

      defaultDir=/srv/http/default
      mkdir -p $defaultDir
      [ -f $defaultDir/index.html ] || touch $defaultDir/index.html
    '';
  };
}
