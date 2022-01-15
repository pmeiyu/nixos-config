{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.jellyfin;
in
{
  options = {
    my.jellyfin.enable = mkEnableOption "Jellyfin.";
  };

  config = mkIf cfg.enable {
    services.jellyfin.enable = true;

    # Hardware acceleration.  Grant permission on /dev/dri/renderD128.
    users.users.jellyfin.extraGroups = [ "render" ];

    services.nginx = {
      virtualHosts.localhost = {
        locations."/jellyfin" = {
          proxyPass = "http://localhost:8096";
          proxyWebsockets = true;
        };
      };
    };
  };
}
