{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../snippets/nanopi-r5s.nix
    ./hardware-configuration.nix
    ./private.nix
  ];

  my.desktop.enable = true;

  my.dns.hosts = [
    "10.1.0.1 pi.home"
  ];
  my.nginx.enable = true;
  my.overlay-networks.enable = true;
  my.samba.enable = true;
  my.syncthing.enable = true;
  my.webdav.enable = true;


  ## Kernel

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
  };


  ## Environment

  networking.hostName = "pi";


  ## Network

  networking.search = [ ];

  networking.firewall = {
    enable = true;
    interfaces.wan0 = {
      allowedTCPPorts = [ ];
    };
    interfaces.br-lan = {
      allowedTCPPorts = [ 53 445 631 ];
      allowedUDPPorts = [ 53 67 5353 ];
    };
  };


  networking.nat = {
    enable = true;
    enableIPv6 = true;
    internalIPs = [ "10.1.0.0/24" ];
    internalIPv6s = [ "fd00:1::0/64" ];
  };

  networking.bridges."br-lan" = {
    interfaces = [ "lan1" "lan2" ];
  };
  networking.interfaces."br-lan" = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "10.1.0.1";
      prefixLength = 24;
    }];
    ipv6.addresses = [{
      address = "fd00:1::1";
      prefixLength = 64;
    }];
  };

  networking.networkmanager.unmanaged = [ "interface-name:wlan0" ];

  # Hijack DNS requests.
  networking.nftables.tables.nat = {
    family = "inet";
    content = ''
      chain prerouting {
          type nat hook prerouting priority dstnat; policy accept;

          ip saddr 10.1.0.0/24 ip daddr != 10.1.0.1 udp dport 53 counter dnat 127.0.0.1:53
          ip saddr 10.1.0.0/24 ip daddr != 10.1.0.1 tcp dport 53 counter dnat 127.0.0.1:53

          ip6 saddr fd00:1::/64 ip6 daddr != fd00:1::1 udp dport 53 counter dnat [fd00:1::1]:53
          ip6 saddr fd00:1::/64 ip6 daddr != fd00:1::1 tcp dport 53 counter dnat [fd00:1::1]:53
      }
    '';
  };


  ## Programs

  environment.systemPackages = with pkgs; [
    iw
    mmc-utils
  ];


  ## Services

  users.users = {
    meiyu = {
      extraGroups = [ "deluge" "docker" ];
    };
    mengyu = {
      isNormalUser = true;
      uid = 1001;
      shell = pkgs.shadow;
    };
  };

  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [ "br-lan" ];
      };
      valid-lifetime = 86400;
      lease-database = {
        type = "memfile";
      };
      option-data = [
        {
          name = "domain-name";
          data = "home";
        }
        {
          name = "domain-search";
          data = "home";
        }
        {
          name = "domain-name-servers";
          data = "10.1.0.1";
        }
        {
          name = "routers";
          data = "10.1.0.1";
        }
      ];
      subnet4 = [{
        subnet = "10.1.0.0/24";
        pools = [
          { pool = "10.1.0.20 - 10.1.0.100"; }
        ];
        reservations = [
          {
            hw-address = "a0:69:d9:e9:03:ae";
            ip-address = "10.1.0.2";
          }
          {
            hw-address = "a8:a1:59:49:72:c5";
            ip-address = "10.1.0.10";
          }
          {
            hw-address = "ac:16:2d:cd:ed:8f";
            ip-address = "10.1.0.16";
          }
        ];
      }];
    };
  };

  services.radvd = {
    enable = true;
    config = ''
      interface br-lan {
        AdvSendAdvert on;
        prefix fd00:1::/64 { };
        RDNSS fd00:1::1 { };
      };
    '';
  };

  services.routedns = {
    settings = {
      listeners.lan = {
        address = "10.1.0.1:53";
        protocol = "udp";
        resolver = "lan";
      };
      listeners.lan-ipv6 = {
        address = "[fd00:1::1]:53";
        protocol = "udp";
        resolver = "lan";
      };
      groups = {
        lan = {
          type = "cache";
          resolvers = [ "lan-block-garbage" ];
        };
        lan-block-garbage = {
          type = "blocklist-v2";
          resolvers = [ "block-dotless-domains" ];
          blocklist-source = [
            { format = "domain"; source = "${pkgs.hosts}/routedns/ad"; }
          ];
        };
      };
    };
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
    allowInterfaces = [ "br-lan" ];
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.printing = {
    enable = true;
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    browsing = true;
    drivers = with pkgs; [ foo2zjs hplip ];
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings = { };
    autoPrune.enable = true;
  };
}
