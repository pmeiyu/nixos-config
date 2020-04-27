{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.yubikey;
in {
  options = { my.yubikey = { enable = mkEnableOption "Enable YubiKey."; }; };

  config = mkIf cfg.enable {
    hardware.u2f.enable = true;
    services.udev.packages = with pkgs; [ yubikey-personalization ];

    # Smart card
    services.pcscd.enable = true;

    environment.systemPackages = with pkgs;
      [ yubico-piv-tool yubikey-personalization ]
      ++ optionals (config.services.xserver.enable) [
        yubioath-desktop
        yubikey-personalization-gui
      ];
  };
}
