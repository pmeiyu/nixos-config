{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.raspberry-pi;
in {
  imports = [ ./fan-control ];

  options = {
    my.raspberry-pi = {
      enable = mkEnableOption "Enable configurations for Raspberry Pi 4.";
      audio = {
        enable = mkEnableOption "Enable audio.";
        pulseaudio.systemWide = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Enable system-wide PulseAudio.
          '';
        };
      };
      gpu = {
        enable = mkEnableOption "Enable GPU.";
        mem = mkOption {
          type = types.int;
          default = 128;
          description = ''
            GPU memory in megabytes.
          '';
        };
      };
      hdmi = {
        force-hot-plug = mkEnableOption
          "Enable HDMI output mode even if no HDMI monitor is detected.";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.loader.grub.enable = false;
    boot.loader.raspberryPi = {
      enable = true;
      version = 4;
      firmwareConfig = ''
        ${optionalString cfg.audio.enable "dtparam=audio=on"}
        ${optionalString cfg.gpu.enable "gpu_mem=${toString cfg.gpu.mem}"}
      '';
    };

    hardware.pulseaudio.systemWide =
      mkIf cfg.audio.enable cfg.audio.pulseaudio.systemWide;

    hardware.deviceTree = mkIf cfg.gpu.enable {
      base = pkgs.device-tree_rpi;
      overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
    };

    hardware.opengl = mkIf cfg.gpu.enable {
      enable = true;
      setLdLibraryPath = true;
      package = pkgs.mesa_drivers;
    };

    services.xserver = {
      videoDrivers = if cfg.gpu.enable then [ "modesetting" ] else [ "fbdev" ];
    };
  };
}
