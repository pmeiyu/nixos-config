{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.cloudflared;
in {
  options = {
    my.cloudflared = { enable = mkEnableOption "Enable cloudflared."; };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    systemd.services.cloudflared = {
      description = "cloudflared";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared"
          + " tunnel --url localhost:80";
      };
    };
  };
}
