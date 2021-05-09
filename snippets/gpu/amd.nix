{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.kernelParams = [
    # Enable AMD GPU overclocking.
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  # Enable OpenCL
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
}
