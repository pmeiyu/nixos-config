{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.open = true;

  programs.sway.extraOptions = [ "--unsupported-gpu" ];
}
