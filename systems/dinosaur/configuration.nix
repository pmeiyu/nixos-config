{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../snippets/cpu/intel.nix
    ../../snippets/gpu/intel.nix
    ../../snippets/gpu/nvidia.nix
    ../../snippets/development.nix
    ../../snippets/tpm.nix
    ./hardware-configuration.nix
    ./private.nix
  ];

  my.desktop.enable = true;
  my.desktop.gui.enable = true;

  my.deluge.enable = true;
  my.dns.hosts = [
    "10.1.0.1 pi.home"
  ];
  my.hotspot = {
    enable = true;
    interface = "wlan0";
    ssid = "Matrix-I";
    password = lib.mkDefault "12345678";
    version = 4;
    channel = 13;
    countryCode = "US";
    block.ad = true;
  };
  my.hydroxide.enable = true;
  my.jellyfin.enable = true;
  my.mpd.enable = true;
  my.monitor.enable = true;
  my.nginx.enable = true;
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
      INTERVAL=20
      DEVPATH=hwmon4=devices/platform/nct6775.656
      DEVNAME=hwmon4=nct6798
      FCTEMPS=hwmon4/pwm1=hwmon4/temp7_input hwmon4/pwm2=hwmon4/temp2_input hwmon4/pwm7=hwmon4/temp7_input
      FCFANS=hwmon4/pwm1=hwmon4/fan1_input   hwmon4/pwm2=hwmon4/fan2_input  hwmon4/pwm7=hwmon4/fan7_input
      MINTEMP= hwmon4/pwm1=40  hwmon4/pwm2=45  hwmon4/pwm7=45
      MAXTEMP= hwmon4/pwm1=60  hwmon4/pwm2=70  hwmon4/pwm7=70
      MINSTART=hwmon4/pwm1=20  hwmon4/pwm2=0   hwmon4/pwm7=0
      MINSTOP= hwmon4/pwm1=15  hwmon4/pwm2=0   hwmon4/pwm7=0
      MAXPWM=  hwmon4/pwm1=80  hwmon4/pwm2=1   hwmon4/pwm7=100
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
    meiyu = {
      extraGroups = [ "deluge" ];
    };
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
    interfaces."tinc*".allowedTCPPorts = [ 445 3389 ];
    interfaces.virbr0.allowedTCPPorts = [ 445 ];
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
