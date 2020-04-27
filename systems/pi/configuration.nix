{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./private.nix

    ../..
  ];

  my.deluge.enable = true;
  my.desktop.enable = true;
  my.network.prefer-ipv4 = true;
  my.nginx.enable = true;
  my.samba.enable = true;
  my.snapper = {
    enable = true;
    enable-store = true;
  };
  my.weechat.enable = true;

  ## Boot loader

  boot.loader.grub.enable = false;
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
    firmwareConfig = ''
      # Enable audio
      dtparam=audio=on

      # HDMI
      hdmi_force_hotplug=1
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

  hardware.pulseaudio.systemWide = true;
  hardware.usbWwan.enable = true;

  ## Environment

  networking.hostName = "pi";

  ## Network

  networking.search = [ ];

  networking.firewall = {
    enable = true;
    extraCommands = ''
      ip6tables -I INPUT -p esp -j ACCEPT

      iptables -I INPUT -p tcp -m tcp -d 192.168.1.0/24 --dport 445 -j ACCEPT
    '';
    extraStopCommands = ''
      ip6tables -D INPUT -p esp -j ACCEPT

      iptables -D INPUT -p tcp -m tcp -d 192.168.1.0/24 --dport 445 -j ACCEPT
    '';
  };

  ## Programs

  environment.systemPackages = with pkgs; [ raspberrypi-tools ];

  ## Services

  services.samba = {
    shares = {
      store = {
        path = "/srv/store";
        browseable = true;
        writable = true;
        "valid users" = "meiyu";
      };
    };
  };

  services.syncthing = {
    enable = true;
    user = "meiyu";
    group = config.users.users.meiyu.group;
    dataDir = config.users.users.meiyu.home;
    openDefaultPorts = true;
  };

  services.tor = {
    enable = true;
    client.enable = true;
    client.transparentProxy.enable = true;
    extraConfig = ''
      Socks5Proxy localhost:1080
    '';
  };
}
