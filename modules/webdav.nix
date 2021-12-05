{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.webdav;
in
{
  options = {
    my.webdav.enable = mkEnableOption "WebDAV server";
  };

  config = mkIf cfg.enable {
    services.nginx = {
      virtualHosts.localhost = {
        locations."/dav/" = {
          proxyPass = "http://localhost:4918";
          extraConfig = ''
            proxy_intercept_errors on;
            error_page 404 = @dav_fallback;
          '';
        };
        locations."/public/" = {
          proxyPass = "http://localhost:4918";
        };
        locations."/user/" = {
          proxyPass = "http://localhost:4918";
        };

        # Some buggy WebDAV clients omit trailing slash when operating a
        # directory, which leads to 404 error.  This fallback adds a trailing
        # slash to request URL.
        locations."@dav_fallback" = {
          extraConfig = ''
            rewrite ^(.*[^/])$ $1/ last;
          '';
        };
      };
    };

    services.webdav-server-rs = {
      enable = true;
      settings = {
        server.listen = [ "127.0.0.1:4918" "[::1]:4918" ];
        accounts = {
          auth-type = "htpasswd.default";
          acct-type = "unix";
        };
        htpasswd.default = {
          htpasswd = "/etc/secrets/webdav";
        };
        location = [
          {
            route = [ "/public/*path" ];
            directory = "/srv/public";
            handler = "filesystem";
            methods = [ "webdav-rw" ];
            autoindex = true;
            auth = "false";
          }
          {
            route = [ "/user/:user/*path" ];
            directory = "~";
            handler = "filesystem";
            methods = [ "webdav-rw" ];
            autoindex = true;
            auth = "true";
            setuid = true;
          }
        ];
      };
    };
  };
}
