{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  programs.sway.extraOptions = [ "--unsupported-gpu" ];
}
