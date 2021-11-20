{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.mpd;
in
{
  options = {
    my.mpd.enable = mkEnableOption "Enable MPD.";
  };

  config = mkIf cfg.enable {
    systemd.services.mpd = {
      description = "mpd";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon --stdout";
        User = "meiyu";
      };
    };
  };
}
