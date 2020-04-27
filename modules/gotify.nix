{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.gotify;
in {
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

    services.nginx = {
      virtualHosts.localhost.locations."/gotify/" = {
        extraConfig = ''
          proxy_pass http://localhost:${toString cfg.port};
          rewrite ^/gotify(/.*) $1 break;

          # Proxy WebSocket
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
          proxy_read_timeout 86400;
        '';
      };
    };
  };
}
