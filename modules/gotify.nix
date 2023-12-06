{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.gotify;
in
{
  options = {
    my.gotify = {
      enable = mkEnableOption "Enable Gotify.";
      port = mkOption {
        type = types.int;
        default = 8386;
        description = "Gotify port.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.gotify = {
      enable = true;
      port = cfg.port;
    };

    systemd.services.gotify-server.environment = {
      GOTIFY_SERVER_CORS_ALLOWORIGINS="- .*";
      GOTIFY_SERVER_STREAM_ALLOWEDORIGINS="- .*";
    };

    services.nginx = {
      virtualHosts.localhost.locations."/gotify/" = {
        proxyPass = "http://localhost:${toString cfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          rewrite ^/gotify(/.*) $1 break;
        '';
      };
    };
  };
}
