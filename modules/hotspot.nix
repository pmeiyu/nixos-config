{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.hotspot;
in
{
  options = {
    my.hotspot = {
      enable = mkEnableOption "Enable WiFi hotspot.";
      interface = mkOption {
        type = types.str;
        default = "wlan0";
        description = "Network interface.";
      };
      ssid = mkOption {
        type = types.str;
        description = "SSID.";
      };
      password = mkOption {
        type = types.str;
        description = "WiFi password.";
      };
      version = mkOption {
        type = types.enum [ 4 5 6 ];
        default = 4;
        description = "WiFi version.";
      };
      band = mkOption {
        default = "2g";
        type = types.enum [ "2g" "5g" "6g" "60g" ];
        description = "Frequency band";
      };
      channel = mkOption {
        type = types.int;
        default = 0;
        description = "Radio frequency channel.";
      };
      countryCode = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "ISO country code.";
      };
      block.ad = mkEnableOption "Block ad.";
      block.fake-news = mkEnableOption "Block fake news.";
      block.gambling = mkEnableOption "Block gambling.";
      block.porn = mkEnableOption "Block porn.";
      block.social = mkEnableOption "Block social networks.";
    };
  };

  config = mkIf cfg.enable {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = "1";
      "net.ipv6.conf.all.forwarding" = "1";
    };

    services.hostapd = {
      enable = true;
      radios."${cfg.interface}" = {
        band = cfg.band;
        channel = cfg.channel;
        countryCode = cfg.countryCode;
        noScan = true;
        settings = {
        };
        wifi4 = {
          enable = cfg.version >= 4;
        };
        wifi5 = {
          enable = cfg.version >= 5;
        };
        networks."${cfg.interface}" = {
          ssid = cfg.ssid;
          authentication = {
            mode = "wpa2-sha256";
            wpaPassword = cfg.password;
          };
          settings = {
          };
        };
      };
    };

    services.kea.dhcp4 = {
      enable = true;
      settings = {
        interfaces-config = {
          interfaces = [ cfg.interface ];
        };
        valid-lifetime = 86400;
        lease-database = {
          type = "memfile";
          persist = false;
        };
        option-data = [
          {
            name = "domain-name";
            data = "lan";
          }
          {
            name = "domain-search";
            data = "lan, xqzp.net";
          }
          {
            name = "domain-name-servers";
            data = "10.10.0.1";
          }
          {
            name = "routers";
            data = "10.10.0.1";
          }
        ];
        subnet4 = [{
          subnet = "10.10.0.0/24";
          pools = [{ pool = "10.10.0.10 - 10.10.0.100"; }];
        }];
      };
    };

    services.radvd = {
      enable = true;
      config = ''
        interface ${cfg.interface} {
          AdvSendAdvert on;
          prefix fd00:10::/64 { };
        };
      '';
    };

    networking.networkmanager.unmanaged = [ "interface-name:${cfg.interface}" ];
    networking.interfaces."${cfg.interface}" = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "10.10.0.1";
        prefixLength = 24;
      }];
      ipv6.addresses = [{
        address = "fd00:10::1";
        prefixLength = 64;
      }];
    };

    services.routedns = {
      settings = {
        listeners.hotspot = {
          address = "10.10.0.1:53";
          protocol = "udp";
          resolver = "hotspot";
        };
        listeners.hotspot-ipv6 = {
          address = "[fd00:10::1]:53";
          protocol = "udp";
          resolver = "hotspot";
        };
        groups = {
          hotspot = {
            type = "cache";
            resolvers = [ "hotspot-block-garbage" ];
          };
          hotspot-block-garbage = {
            type = "blocklist-v2";
            resolvers = [ "block-dotless-domains" ];
            blocklist-source = [
            ] ++ (optionals cfg.block.ad [
              { format = "domain"; source = "${pkgs.hosts}/routedns/ad"; }
            ]) ++ (optionals cfg.block.fake-news [
              { format = "domain"; source = "${pkgs.hosts}/routedns/fakenews"; }
            ]) ++ (optionals cfg.block.gambling [
              { format = "domain"; source = "${pkgs.hosts}/routedns/gambling"; }
            ]) ++ (optionals cfg.block.porn [
              { format = "domain"; source = "${pkgs.hosts}/routedns/porn"; }
            ]) ++ (optionals cfg.block.social [
              { format = "domain"; source = "${pkgs.hosts}/routedns/social"; }
            ]);
          };
        };
      };
    };

    networking.firewall = {
      interfaces."${cfg.interface}" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    };

    networking.nat = {
      enable = true;
      enableIPv6 = true;
      internalIPs = [ "10.10.0.0/24" ];
      internalIPv6s = [ "fd00:10::0/64" ];
    };

    # Hijack DNS requests.
    networking.nftables = {
      ruleset = ''
        table inet nat {
            chain prerouting {
                type nat hook prerouting priority dstnat; policy accept;

                ip saddr 10.10.0.0/24 ip daddr != 10.10.0.1 udp dport 53 counter dnat 127.0.0.1:53
                ip saddr 10.10.0.0/24 ip daddr != 10.10.0.1 tcp dport 53 counter dnat 127.0.0.1:53

                ip6 saddr fd00:10::/64 ip6 daddr != fd00:10::1 udp dport 53 counter dnat [fd00:10::1]:53
                ip6 saddr fd00:10::/64 ip6 daddr != fd00:10::1 tcp dport 53 counter dnat [fd00:10::1]:53
            }
        }
      '';
    };
  };
}
