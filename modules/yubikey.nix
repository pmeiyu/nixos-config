{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.yubikey;
in
{
  options = { my.yubikey = { enable = mkEnableOption "Enable YubiKey."; }; };

  config = mkIf cfg.enable {
    services.udev.packages = with pkgs; [ yubikey-personalization ];

    # Smart card
    services.pcscd.enable = true;

    environment.systemPackages = with pkgs;
      [ yubico-piv-tool yubikey-manager yubikey-personalization ]
      ++ optionals (config.services.xserver.enable) [
        yubioath-desktop
        yubikey-manager-qt
        yubikey-personalization-gui
      ];
  };
}
