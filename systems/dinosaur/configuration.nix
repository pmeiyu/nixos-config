{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../snippets/cpu/intel.nix
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
    interface = "wlan0";
    ssid = "Castle";
    password = lib.mkDefault "12345678";
    version = 4;
    channel = 6;
    countryCode = "US";
    ht_capab = "[HT40+][RX-STBC1]";
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
  my.webdav.enable = true;
  my.weechat.enable = true;


  ## Boot loader

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  ## Hardware

  hardware.fancontrol = {
    enable = true;
    config = ''
      INTERVAL=10
      DEVPATH=hwmon2=devices/platform/nct6775.656
      DEVNAME=hwmon2=nct6798
      FCTEMPS=hwmon2/pwm2=hwmon2/temp2_input hwmon2/pwm1=hwmon2/temp7_input hwmon2/pwm7=hwmon2/temp7_input
      FCFANS=hwmon2/pwm2=hwmon2/fan2_input hwmon2/pwm1=hwmon2/fan1_input hwmon2/pwm7=hwmon2/fan7_input
      MINTEMP=hwmon2/pwm2=30 hwmonn2/pwm1=50 hwmon2/pwm7=50
      MAXTEMP=hwmon2/pwm2=70 hwmon2/pwm1=60 hwmon2/pwm7=60
      MINSTART=hwmon2/pwm2=20 hwmon2/pwm1=20 hwmon2/pwm7=20
      MINSTOP=hwmon2/pwm2=0 hwmon2/pwm1=40 hwmon2/pwm7=40
      MAXPWM=hwmon2/pwm2=150 hwmon2/pwm1=80 hwmon2/pwm7=80
    '';
  };


  ## Kernel

  boot.extraModulePackages = with config.boot.kernelPackages; [
    acpi_call
  ];

  boot.kernelModules = [
    "acpi_call"

    # Nuvoton sensor
    "nct6775"

    # VFIO
    "vfio_pci"
  ];

  boot.kernelParams = [
    "intel_iommu=on"

    # Fix GPU PCI passthrough bug.
    "video=efifb:off"
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

    extraCommands = ''
      ip rule add fwmark 100 lookup main priority 100
      ip -6 rule add fwmark 100 lookup main priority 100
    '';
    extraStopCommands = ''
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

  services.clamav = {
    daemon.enable = false;
    updater.enable = true;
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
        proxyWebsockets = true;
        extraConfig = ''
          proxy_pass http://localhost;
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
