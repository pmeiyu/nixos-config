{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.kernelParams = [
    # Fix screen flickering.  Disable "Panel Self Refresh".
    "i915.enable_psr=0"
  ];

  environment.systemPackages = with pkgs; [
    intel-gpu-tools

    # WWAN utilities
    libmbim
    libqmi
    minicom
  ];

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Intel GPU Hardware Acceleration
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    libvdpau-va-gl
    vaapiIntel
    vaapiVdpau
  ];

  hardware.trackpoint = {
    enable = true;
    emulateWheel = true;
  };

  services.fprintd.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      # Internal battery
      START_CHARGE_THRESH_BAT0 = 70;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # Replaceable battery
      START_CHARGE_THRESH_BAT1 = 70;
      STOP_CHARGE_THRESH_BAT1 = 80;
    };
  };
}
