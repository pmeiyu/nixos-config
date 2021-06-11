{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../snippets/cpu/amd.nix
    ../../snippets/gpu/amd.nix
    ../../snippets/development.nix
    ./hardware-configuration.nix
    ./private.nix
  ];

  my.deluge.enable = true;
  my.desktop.enable = true;
  my.desktop.gui.enable = true;
  my.gotify.enable = true;
  my.hotspot = {
    enable = true;
    ssid = "Castle";
    password = lib.mkDefault "12345678";
    version = 4;
    interface = "wlan0";
    channel = 6;
    countryCode = "US";
    ht_capab = "[HT40+][SHORT-GI-40][RX-STBC1][TX-STBC]";
    block.ad = true;
  };
  my.hydroxide.enable = true;
  my.mpd.enable = true;
  my.monitor.enable = true;
  my.network.prefer-ipv4 = true;
  my.nginx.enable = true;
  my.overlay-networks.enable = true;
  my.samba.enable = true;
  my.snapper = {
    enable = true;
    enable-home = true;
  };
  my.syncthing.enable = true;
  my.virtualization.enable = true;
  my.weechat.enable = true;

  ## Nix

  nix.maxJobs = 8;

  ## Boot loader

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ## Hardware

  hardware.fancontrol = {
    enable = true;
    config = ''
      INTERVAL=10
      DEVPATH=hwmon1=devices/platform/nct6775.656
      DEVNAME=hwmon1=nct6792
      FCTEMPS=hwmon1/pwm2=hwmon1/temp7_input hwmon1/pwm1=hwmon1/temp3_input hwmon1/pwm3=hwmon1/temp3_input
      FCFANS=hwmon1/pwm2=hwmon1/fan2_input hwmon1/pwm1=hwmon1/fan1_input hwmon1/pwm3=hwmon1/fan3_input
      MINTEMP=hwmon1/pwm2=30 hwmon1/pwm1=40 hwmon1/pwm3=40
      MAXTEMP=hwmon1/pwm2=70 hwmon1/pwm1=60 hwmon1/pwm3=60
      MINSTART=hwmon1/pwm2=20 hwmon1/pwm1=20 hwmon1/pwm3=20
      MINSTOP=hwmon1/pwm2=0 hwmon1/pwm1=50 hwmon1/pwm3=50
      MAXPWM=hwmon1/pwm1=80 hwmon1/pwm3=80
    '';
  };

  ## Kernel

  boot.kernelModules = [
    "acpi_call"

    # For Nuvoton NCT6792D Super IO Sensors on motherboard.
    "nct6775"

    # VFIO
    "vfio_pci"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.kernelParams = [
    "amd_iommu=on"

    # Fix AMD Radeon RX 5500 XT quirk.
    "pci=noats"
  ];

  ## Environment

  networking.hostName = "dinosaur";

  ## User accounts

  users.users = {
    mengyu = {
      isNormalUser = true;
      uid = 1001;
      shell = pkgs.shadow;
    };
  };

  ## Network

  networking.search = [ ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8443 ];
    interfaces.wlan0.allowedTCPPorts = [ 445 3389 ];
    interfaces."tinc+".allowedTCPPorts = [ 445 3389 ];
    interfaces.virbr0.allowedTCPPorts = [ 445 ];

    extraPackages = [ pkgs.iproute pkgs.ipset ];
    extraCommands = ''
      ip6tables -w -I INPUT -p esp -j ACCEPT
      ip6tables -w -I INPUT -p gre -j ACCEPT

      ipset create -exist china4 hash:ip family inet
      ipset create -exist china6 hash:ip family inet6
      iptables -w -I PREROUTING -t mangle -m set --match-set china4 dst -j MARK --set-mark 100
      ip6tables -w -I PREROUTING -t mangle -m set --match-set china6 dst -j MARK --set-mark 100
      ip rule add fwmark 100 lookup main priority 100
      ip -6 rule add fwmark 100 lookup main priority 100
    '';
    extraStopCommands = ''
      ip6tables -w -D INPUT -p esp -j ACCEPT
      ip6tables -w -D INPUT -p gre -j ACCEPT

      ipset flush china4
      ipset flush china6
      iptables -w -D PREROUTING -t mangle -m set --match-set china4 dst -j MARK --set-mark 100
      ip6tables -w -D PREROUTING -t mangle -m set --match-set china6 dst -j MARK --set-mark 100
      ip rule delete fwmark 100 lookup main priority 100
      ip -6 rule delete fwmark 100 lookup main priority 100
    '';
  };

  ## Programs

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  environment.systemPackages = with pkgs; [
    certbot
    edac-utils

    # WWAN utilities
    libmbim
    minicom
  ];

  ## Services

  services.xserver.desktopManager.gnome.enable = true;

  services.xrdp = {
    enable = true;
    defaultWindowManager = "i3";
  };

  services.guix.enable = true;

  services.nginx = {
    virtualHosts."earth.xqzp.net" = {
      listen = [
        { addr = "0.0.0.0"; port = 80; ssl = false; }
        { addr = "[::]"; port = 80; ssl = false; }
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "[::]"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 8443; ssl = true; }
        { addr = "[::]"; port = 8443; ssl = true; }
      ];
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        extraConfig = ''
          proxy_pass http://localhost;

          # Proxy WebSocket
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
          proxy_read_timeout 86400;
        '';
      };
      extraConfig = ''
        access_log /var/log/nginx/earth.access.log;
        error_log /var/log/nginx/earth.error.log;
      '';
    };
  };

  services.samba = {
    shares = {
      srv = {
        path = "/srv";
        browseable = true;
        writable = true;
        "valid users" = "meiyu";
      };
    };
  };
}
