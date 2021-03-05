{ config, lib, pkgs, ... }:

{
  # https://nixos.wiki/wiki/Bluetooth

  hardware.bluetooth.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };

  services.blueman.enable = true;
}
