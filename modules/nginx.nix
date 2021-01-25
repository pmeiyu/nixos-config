{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.nginx;
in
{
  options = { my.nginx = { enable = mkEnableOption "Enable Nginx."; }; };

  config = mkIf cfg.enable {
    security.acme.acceptTerms = true;
    security.acme.email = "acme@pengmeiyu.com";

    services.nginx = {
      enable = true;
      resolver.addresses = [ "[::1]" ];
      virtualHosts.localhost = {
        default = mkDefault true;
        locations."/" = {
          root = "/srv/www/default";
          index = "index.html";
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
    };

    system.activationScripts.my-nginx = ''
      mkdir -p /var/log/nginx && chown -R nginx:nginx /var/log/nginx

      mkdir -p /srv/www/default
      [ -f /srv/www/default/index.html ] || touch /srv/www/default/index.html
    '';
  };
}
