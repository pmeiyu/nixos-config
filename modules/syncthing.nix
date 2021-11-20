{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.syncthing;
in
{
  options = {
    my.syncthing.enable = mkEnableOption "Enable Syncthing.";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "meiyu";
      group = config.users.users.meiyu.group;
      dataDir = config.users.users.meiyu.home;
      openDefaultPorts = true;
    };
  };
}
