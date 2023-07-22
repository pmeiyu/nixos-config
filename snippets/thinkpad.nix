{ config, lib, pkgs, ... }:

{
  imports = [
    ./cpu/intel.nix
    ./gpu/intel.nix
  ];

  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  environment.systemPackages = with pkgs; [
    # WWAN utilities
    libmbim
  ];

  hardware.bluetooth.enable = true;

  hardware.trackpoint = {
    enable = true;
    emulateWheel = true;
  };

  services.fprintd.enable = true;

  services.fwupd.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      # Internal battery
      START_CHARGE_THRESH_BAT0 = lib.mkDefault 70;
      STOP_CHARGE_THRESH_BAT0 = lib.mkDefault 80;

      # Replaceable battery
      START_CHARGE_THRESH_BAT1 = lib.mkDefault 70;
      STOP_CHARGE_THRESH_BAT1 = lib.mkDefault 80;

      # CPU
      CPU_SCALING_GOVERNOR_ON_AC = lib.mkDefault "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = lib.mkDefault "powersave";
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
