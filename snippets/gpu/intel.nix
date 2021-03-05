{ config, lib, pkgs, ... }:

{
  boot.initrd.kernelModules = [ "i915" ];

  environment.systemPackages = with pkgs; [
    intel-gpu-tools
  ];

  services.xserver.videoDrivers = [ "modesetting" ];

  # Intel GPU hardware acceleration
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    libvdpau-va-gl
    vaapiIntel
    vaapiVdpau
  ];
}
