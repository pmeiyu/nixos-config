{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../snippets/development.nix
    ./hardware-configuration.nix
    ./private.nix
  ];

  my.deluge.enable = true;
  my.desktop.enable = true;
  my.desktop.gui.enable = true;
  my.dns.block.ipv6 = true;
  my.hotspot = {
    enable = true;
    interface = "wlan0";
    ssid = "Castle";
    password = lib.mkDefault "12345678";
  };
  my.hydroxide.enable = true;
  my.mpd.enable = true;
  my.monitor.enable = true;
  my.network.prefer-ipv4 = true;
  my.nginx.enable = true;
  my.overlay-networks.enable = true;
  my.samba.enable = true;
  my.syncthing.enable = true;
  my.virtualization.enable = true;
  my.weechat.enable = true;

  ## Nix

  nix.maxJobs = 8;

  ## Boot loader

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ## Hardware

  hardware.cpu.amd.updateMicrocode = true;
  hardware.pulseaudio.systemWide = true;
  hardware.usbWwan.enable = true;

  # Rename LTE modem
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", DRIVERS=="?*", ATTR{address}=="0c:5b:8f:27:9a:64", NAME="wwan0"
  '';

  ## Kernel

  boot.kernelModules = [
    "acpi_call"

    # For motherboard sensors.
    "it87"

    # VFIO
    "vfio_pci"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.kernelParams = [ "amd_iommu=on" ];

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
    allowedTCPPorts = [ ];
    interfaces."eth+".allowedTCPPorts = [ 445 ];
    interfaces.wlan0.allowedTCPPorts = [ 445 3389 ];
    interfaces."tinc+".allowedTCPPorts = [ 445 3389 ];
    interfaces.virbr0.allowedTCPPorts = [ 445 ];

    extraPackages = [ pkgs.iproute pkgs.ipset ];
    extraCommands = ''
      ip6tables -I INPUT -p esp -j ACCEPT

      ipset create -exist china4 hash:ip family inet
      ipset create -exist china6 hash:ip family inet6
      iptables -I PREROUTING -t mangle -m set --match-set china4 dst -j MARK --set-mark 100
      ip6tables -I PREROUTING -t mangle -m set --match-set china6 dst -j MARK --set-mark 100
      ip rule add fwmark 100 lookup main priority 100
      ip -6 rule add fwmark 100 lookup main priority 100
    '';
    extraStopCommands = ''
      ip6tables -D INPUT -p esp -j ACCEPT

      ipset flush china4
      ipset flush china6
      iptables -D PREROUTING -t mangle -m set --match-set china4 dst -j MARK --set-mark 100
      ip6tables -D PREROUTING -t mangle -m set --match-set china6 dst -j MARK --set-mark 100
      ip rule delete fwmark 100 lookup main priority 100
      ip -6 rule delete fwmark 100 lookup main priority 100
    '';
  };

  ## Programs

  environment.systemPackages = with pkgs; [ edac-utils ];

  ## Services

  services.xserver.desktopManager.gnome3.enable = true;

  services.xrdp = {
    enable = true;
    defaultWindowManager = "i3";
  };

  services.guix = {
    enable = true;
    publish.enable = true;
    mirror.enable = true;
    mirror.upstream = "mirror.guix.org.cn";
  };

  services.nginx = {
    virtualHosts."earth.pengmeiyu.com" = {
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
        access_log /var/log/nginx/earth.pengmeiyu.com.access.log;
        error_log /var/log/nginx/earth.pengmeiyu.com.error.log;
      '';
    };
  };

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
}
