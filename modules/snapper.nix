{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.snapper;
in
{
  options = {
    my.snapper = {
      enable = mkEnableOption "Enable Snapper.";
      enable-home = mkEnableOption "Enable Snapper for /home.";
      enable-store = mkEnableOption "Enable Snapper for /srv/store.";
    };
  };

  config = mkIf cfg.enable {
    services.snapper = {
      snapshotInterval = "hourly";
      cleanupInterval = "1d";
      configs = {
        home = mkIf cfg.enable-home {
          subvolume = "/home";
          extraConfig = ''
            ALLOW_GROUPS="wheel"
            TIMELINE_CREATE="yes"
            TIMELINE_CLEANUP="yes"
          '';
        };
        "srv-store" = mkIf cfg.enable-store {
          subvolume = "/srv/store";
          extraConfig = ''
            ALLOW_GROUPS="wheel"
            TIMELINE_CREATE="yes"
            TIMELINE_CLEANUP="yes"
          '';
        };
      };
    };

    system.activationScripts.my-snapper = concatMapStrings
      (x: ''
        [ -e ${x}/.snapshots ] || \
            ${pkgs.btrfs-progs}/bin/btrfs subvolume create ${x}/.snapshots
      '')
      (mapAttrsToList (name: value: value.subvolume)
        config.services.snapper.configs);
  };
}
