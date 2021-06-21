{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  programs.sway.extraOptions = [ "--my-next-gpu-wont-be-nvidia" ];
}
