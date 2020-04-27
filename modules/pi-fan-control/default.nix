{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.pi-fan-control;
  python = pkgs.python3.withPackages
    (python-packages: with python-packages; [ python-periphery ]);
in {
  options = {
    my.pi-fan-control = {
      enable = mkEnableOption "Enable fan control for Raspberry Pi.";
      gpio-pin = mkOption {
        type = types.int;
        default = 17;
        description = ''
          GPIO pin to control the fan.
        '';
      };
      on-threshold = mkOption {
        type = types.int;
        default = 70;
        description = ''
          Threshold temperature to turn on the fan.
        '';
      };
      off-threshold = mkOption {
        type = types.int;
        default = 45;
        description = ''
          Threshold temperature to turn off the fan.
        '';
      };
      sleep-interval = mkOption {
        type = types.int;
        default = 10;
        description = ''
          Check temperature every $x seconds.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.pi-fan-control = {
      description = "Raspberry Pi fan control";
      wantedBy = [ "basic.target" ];
      serviceConfig.ExecStart = "${python}/bin/python ${./pi-fan-control.py}"
        + " --gpio-pin ${toString cfg.gpio-pin}"
        + " --on-threshold ${toString cfg.on-threshold}"
        + " --off-threshold ${toString cfg.off-threshold}"
        + " --sleep-interval ${toString cfg.sleep-interval}";
    };
  };
}
