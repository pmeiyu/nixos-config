{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.deluge;
in
{
  options = { my.deluge = { enable = mkEnableOption "Enable Deluge."; }; };

  config = mkIf cfg.enable {
    services.deluge = {
      enable = true;
      web.enable = true;
    };

    services.nginx = {
      virtualHosts.localhost.locations."/deluge/" = {
        extraConfig = ''
          proxy_pass http://localhost:${toString config.services.deluge.web.port}/;
          proxy_set_header X-Deluge-Base "/deluge/";
          add_header X-Frame-Options SAMEORIGIN;

          # Allow uploading large torrent files.
          client_max_body_size 10M;
        '';
      };
    };
  };
}
