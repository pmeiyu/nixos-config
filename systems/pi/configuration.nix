{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./private.nix

    ../..
  ];

  my.deluge.enable = true;
  my.desktop.enable = true;
  my.hotspot = {
    enable= true;
    interface = "wlan0";
    ssid = "Pi";
  };
  my.network.prefer-ipv4 = true;
  my.nginx.enable = true;
  my.samba.enable = true;
  my.weechat.enable = true;

  ## Nix

  nix.binaryCaches = lib.mkForce [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store/"
    "https://cache.nixos.org/"
  ];

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

  # Rename LTE modem
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", DRIVERS=="?*", ATTR{address}=="0c:5b:8f:27:9a:64", NAME="wwan0"
  '';

  ## Environment

  networking.hostName = "pi";

  ## Network

  networking.search = [ ];

  networking.firewall = {
    enable = true;
    extraCommands = ''
      ip6tables -I INPUT -p esp -j ACCEPT

      iptables -I INPUT -p tcp -m tcp -d 10.10.0.0/24 --dport 445 -j ACCEPT
      iptables -I INPUT -p tcp -m tcp -d 192.168.1.0/24 --dport 445 -j ACCEPT
    '';
    extraStopCommands = ''
      ip6tables -D INPUT -p esp -j ACCEPT

      iptables -D INPUT -p tcp -m tcp -d 10.10.0.0/24 --dport 445 -j ACCEPT
      iptables -D INPUT -p tcp -m tcp -d 192.168.1.0/24 --dport 445 -j ACCEPT
    '';
  };

  ## Programs

  environment.systemPackages = with pkgs; [ iw raspberrypi-tools ];

  ## Services

  services.dnsmasq.extraConfig = ''
    conf-dir=/etc/dnsmasq.d/,*.conf
  '';

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
