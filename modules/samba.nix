{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.samba;
in
{
  options = {
    my.samba.enable = mkEnableOption "Enable Samba.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ samba ];

    services.samba = {
      enable = true;
      extraConfig = ''
        client min protocol = SMB3_00

        load printers = no
        printcap name = /dev/null
      '';
      shares = {
        homes = {
          "valid users" = "%S";
          browseable = false;
          writable = true;
        };
        # Hide "guest" folder
        guest = {
          browseable = false;
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
