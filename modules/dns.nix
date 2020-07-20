{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.dns;
in {
  options = {
    my.dns = {
      enable = mkEnableOption "Enable local DNS server.";
      dnssec.enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable DNSSEC.
        '';
      };
      adblock.enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable hosts file for adblock.
        '';
      };
      dnsmasq-china-list.enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable dnsmasq-china-list.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    networking.nameservers = [ "::1" ];
    networking.networkmanager.dns = "none";

    services.dnscrypt-proxy2 = {
      enable = true;
      settings = {
        listen_addresses = [ "[::1]:54" ];
        require_dnssec = cfg.dnssec.enable;
        require_nolog = true;
        require_nofilter = true;
        fallback_resolver = "9.9.9.9:53";
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md"
          ];
          cache_file = "public-resolvers.md";
          minisign_key =
            "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          refresh_delay = 72;
        };
      };
    };
    systemd.services.dnscrypt-proxy2 = {
      serviceConfig = {
        Restart = "always";
        RestartSec = "60";
      };
    };

    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      extraConfig = ''
        except-interface=virbr0
        bind-dynamic

        server=::1#54

        no-resolv
        log-queries
        log-dhcp
        cache-size=1000
        min-cache-ttl=600
        local=/lan/
        domain=lan
        # expand-hosts

        ${optionalString cfg.dnssec.enable ''
          dnssec
          conf-file=${pkgs.dnsmasq}/share/dnsmasq/trust-anchors.conf
        ''}

        ${optionalString cfg.adblock.enable ''
          addn-hosts=${pkgs.steven-black-hosts}/hosts
        ''}

        ${optionalString cfg.dnsmasq-china-list.enable ''
          conf-dir=${pkgs.dnsmasq-china-list.dnsmasq}/,*.conf
        ''}

        addn-hosts=/etc/hosts.local
      '';
    };

    networking.firewall = {
      extraCommands = ''
        iptables -I INPUT -p tcp -m tcp -s 10.0.0.0/8 --dport 53 -j ACCEPT
        iptables -I INPUT -p udp -m udp -s 10.0.0.0/8 --dport 53 -j ACCEPT
      '';
      extraStopCommands = ''
        iptables -D INPUT -p tcp -m tcp -s 10.0.0.0/8 --dport 53 -j ACCEPT
        iptables -D INPUT -p udp -m udp -s 10.0.0.0/8 --dport 53 -j ACCEPT
      '';
    };
  };
}
