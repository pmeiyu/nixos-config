{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.samba;
in
{
  options = {
    my.samba = {
      enable = mkEnableOption "Enable Samba.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ samba ];

    services.samba = {
      enable = true;
      extraConfig = ''
        client min protocol = SMB3_00
      '' + (optionalString (!config.services.printing.enable) ''
        load printers = no
        printcap name = /dev/null
      '');
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
      } // optionalAttrs config.services.printing.enable {
        printers = {
          comment = "All Printers";
          browseable = false;
          path = "/var/tmp";
          printable = true;
          "guest ok" = true;
          writable = false;
          "create mask" = "0700";
        };
        # Windows clients look for this share name as a source of downloadable
        # printer drivers
        "print$" = {
          comment = "Printer Drivers";
          path = "/var/lib/samba/printers";
          browseable = true;
          writable = false;
          "guest ok" = false;
        };
      };
    };
  };
}
