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
  my.dns.ipset.enable = true;
  my.network.prefer-ipv4 = true;
  my.nginx.enable = true;
  my.samba.enable = true;
  my.weechat.enable = true;

  ## Nix

  nix.binaryCaches =
    [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store/" ];

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

  ## Hardware

  hardware.usbWwan.enable = true;

  ## Environment

  networking.hostName = "pi";

  ## Network

  networking.search = [ ];

  networking.firewall = {
    enable = true;
    extraCommands = ''
      ip6tables -I INPUT -p esp -j ACCEPT
    '';
    extraStopCommands = ''
      ip6tables -D INPUT -p esp -j ACCEPT
    '';
    interfaces.eth0 = {
      allowedTCPPorts = [ 445 ];
    };
    interfaces.wlan0 = {
      allowedTCPPorts = [ 445 ];
    };
  };

  ## Programs

  environment.systemPackages = with pkgs; [ iw raspberrypi-tools ];

  ## Services

  my.hotspot = {
    enable = true;
    interface = "wlan0";
    ssid = "Pi";
    password = "12345678";
  };
  # 802.11ac AP configuration for Raspberry Pi 4B.
  services.hostapd = lib.mkForce {
    hwMode = "a";
    channel = 40;
    countryCode = "US";
    extraConfig = ''
      ieee80211ac=1

      # QoS
      wmm_enabled=1

      # 1 = WPA
      auth_algs=1

      # WPA-PSK = WPA-Personal
      wpa_key_mgmt=WPA-PSK

      # CCMP = AES in Counter mode with CBC-MAC (CCMP-128)
      rsn_pairwise=CCMP
    '';
  };
}
