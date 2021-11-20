{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.gnome-flashback;
in
{
  options = {
    my.gnome-flashback.enable = mkEnableOption "Enable Gnome flashback.";
  };

  config = mkIf cfg.enable {
    nixpkgs.config.packageOverrides = pkgs: rec {
      polybar = pkgs.polybar.override {
        i3Support = true;
        mpdSupport = true;
        pulseSupport = true;
      };
    };

    services.xserver.displayManager.gdm.enable = true;

    services.xserver.desktopManager.gnome = {
      enable = true;
      flashback.customSessions = [{
        wmName = "i3";
        wmLabel = "i3";
        wmCommand = "${pkgs.i3-gaps}/bin/i3";
      }];
    };

    environment.systemPackages = with pkgs; [
      nitrogen
      picom
      polybar
      scrot
      xclip
    ];
  };
}
