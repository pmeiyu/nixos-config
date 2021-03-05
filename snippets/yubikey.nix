{ config, lib, pkgs, ... }:

{
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
}
