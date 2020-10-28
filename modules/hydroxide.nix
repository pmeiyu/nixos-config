{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.hydroxide;
in {
  options.my.hydroxide.enable = mkEnableOption "Enable hydroxide.";

  config = mkIf cfg.enable {
    systemd.services.hydroxide = {
      description = "hydroxide";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.hydroxide}/bin/hydroxide -carddav-port 2806 serve";
        User = "meiyu";
      };
    };
  };
}
