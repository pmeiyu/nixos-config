{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ./hardware-configuration.nix
  ];

  my.raspberry-pi = {
    enable = true;
    audio.enable = true;
    gpu.enable = true;
    hdmi.force-hot-plug = true;
  };

  my.deluge.enable = true;
  my.desktop.enable = true;
  my.network.prefer-ipv4 = true;
  my.nginx.enable = true;
  my.samba.enable = true;
  my.weechat.enable = true;


  ## Boot loader

  boot.loader.raspberryPi = {
    firmwareConfig = ''
      # # Enable HDMI audio
      # hdmi_drive=2
      # # DMT
      # hdmi_group=2
      # # 1920x1080@60Hz
      # hdmi_mode=82
    '';
  };


  ## Kernel

  boot.kernelPackages = pkgs.linuxPackages_rpi4;


  ## Environment

  networking.hostName = "pi";


  ## Network

  networking.search = [ ];

  networking.firewall = {
    enable = true;
    interfaces.eth0 = {
      allowedTCPPorts = [ 445 ];
    };
    interfaces.wlan0 = {
      allowedTCPPorts = [ 445 ];
    };
  };


  ## Programs

  environment.systemPackages = with pkgs; [
    iw
    raspberrypi-tools
  ];


  ## Services

  my.hotspot = {
    enable = true;
    ssid = "Pi";
    password = "12345678";
    version = 5;
    interface = "wlan0";
    channel = 40;
    countryCode = "US";
    block.ad = true;
  };
}
