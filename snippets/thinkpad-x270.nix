{ config, lib, pkgs, ... }:

{
  imports = [
    ./cpu/intel.nix
    ./gpu/intel.nix
  ];

  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.kernelParams = [
    # Disable "Panel Self Refresh".  Fix random freezes.
    "i915.enable_psr=0"
  ];

  environment.systemPackages = with pkgs; [
    # WWAN utilities
    libmbim
    libqmi
    minicom
  ];

  hardware.bluetooth.enable = true;

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

  environment.etc."sensors.d/thinkpad.conf" = {
    text = ''
      chip "thinkpad-isa-0000"
          ignore temp2
          ignore temp3
          ignore temp4
          ignore temp5
          ignore temp6
          ignore temp7
          ignore temp8
          ignore temp9
          ignore temp10
          ignore temp11
          ignore temp12
          ignore temp13
          ignore temp14
          ignore temp15
          ignore temp16
    '';
  };
}
