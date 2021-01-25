{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.bluetooth;
in
{
  options = {
    my.bluetooth = { enable = mkEnableOption "Enable bluetooth."; };
  };

  config = mkIf cfg.enable {
    # https://nixos.wiki/wiki/Bluetooth

    hardware.bluetooth = { enable = true; };

    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };

    services.blueman.enable = true;
  };
}
