{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable OpenCL
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
}
