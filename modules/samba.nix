{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.samba;
in {
  options = { my.samba = { enable = mkEnableOption "Enable Samba."; }; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ samba ];

    services.samba = {
      enable = true;
      shares = {
        homes = {
          "valid users" = "%S";
          browseable = false;
          writable = true;
        };
        public = {
          path = "/srv/public";
          browseable = true;
          writable = true;
          "guest ok" = true;
        };
      };
    };
  };
}
