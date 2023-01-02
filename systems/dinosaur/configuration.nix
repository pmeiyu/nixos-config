{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../snippets/cpu/intel.nix
    ../../snippets/gpu/intel.nix
    ../../snippets/development.nix
    ./hardware-configuration.nix
    ./private.nix
  ];

  my.desktop.enable = true;
  my.desktop.gui.enable = true;

  my.deluge.enable = true;
  my.hotspot = {
    enable = true;
    interface = "wlan0";
    ssid = "Matrix-I";
    password = lib.mkDefault "12345678";
    version = 4;
    channel = 13;
    countryCode = "US";
    ht_capab = "[HT40-][RX-STBC1]";
    block.ad = true;
  };
  my.hydroxide.enable = true;
  my.jellyfin.enable = true;
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

  powerManagement.cpuFreqGovernor = "powersave";

  hardware.fancontrol = {
    enable = true;
    config = ''
      INTERVAL=10
      DEVPATH=hwmon2=devices/platform/nct6775.656
      DEVNAME=hwmon2=nct6798
      FCTEMPS=hwmon2/pwm2=hwmon2/temp2_input
      FCFANS=hwmon2/pwm2=hwmon2/fan2_input
      MINTEMP=hwmon2/pwm2=30
      MAXTEMP=hwmon2/pwm2=70
      MINSTART=hwmon2/pwm2=20
      MINSTOP=hwmon2/pwm2=0
      MAXPWM=hwmon2/pwm2=150
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
      sslCertificate = "/etc/secrets/cert/earth.xqzp.net/cert.pem";
      sslCertificateKey = "/etc/secrets/cert/earth.xqzp.net/key.pem";
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
}
