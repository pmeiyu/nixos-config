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
      additionalModules = [ pkgs.nginxModules.echo ];
      resolver.addresses = [ "[::1]" ];
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
    };

    system.activationScripts.my-nginx = ''
      mkdir -p /var/log/nginx && chown -R nginx:nginx /var/log/nginx

      defaultDir=/srv/http/default
      mkdir -p $defaultDir
      [ -f $defaultDir/index.html ] || touch $defaultDir/index.html
    '';
  };
}
