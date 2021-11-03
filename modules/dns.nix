{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.dns;
in
{
  options = {
    my.dns = {
      enable = mkEnableOption "Enable local DNS server.";
      dnssec.enable = mkEnableOption "Enable DNSSEC.";
      block.ipv6 = mkEnableOption "Do not resolve IPv6 record.";
      block.ad = mkEnableOption "Block ad.";
      block.fake-news = mkEnableOption "Block fake news.";
      block.gambling = mkEnableOption "Block gambling.";
      block.porn = mkEnableOption "Block porn.";
      block.social = mkEnableOption "Block social networks.";
      chinalist.enable = mkEnableOption "Enable dnsmasq-china-list.";
      gfwlist.enable = mkEnableOption "Enable gfwlist.";
      ipset.enable = mkEnableOption "Enable ipset.";
      log.enable = mkEnableOption "Enable log.";
    };
  };

  config = mkIf cfg.enable {
    networking.nameservers = [ "::1" ];
    networking.networkmanager.dns = mkDefault "none";

    services.nginx.resolver.addresses = [ "[::1]" ];

    services.unbound = {
      enable = true;
      enableRootTrustAnchor = cfg.dnssec.enable;
      settings = {
        forward-zone = [{
          name = ".";
          forward-addr = [ "::1@54" ];
        }];
        server = {
          interface = [
            "127.0.0.1@53"
            "::1@53"
          ];
          access-control = [
            "127.0.0.0/8 allow"
            "::1/128 allow"
          ];

          cache-min-ttl = 60;
          cache-max-negative-ttl = 60;
          serve-expired = true;
          do-not-query-localhost = false;

          domain-insecure = [ "home" "lan" "tinc" ];
          private-domain = [ "home" "lan" "tinc" "xqzp.net" ];
          private-address = [
            "10.0.0.0/8"
            "169.254.0.0/16"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "fc00::/7"
            "fe80::/10"
          ];

          access-control-view = [
          ] ++ (optionals cfg.block.ad [
            "127.0.0.0/8 block-ad"
            "::1 block-ad"
          ]) ++ (optionals cfg.block.fake-news [
            "127.0.0.0/8 block-fakenews"
            "::1 block-fakenews"
          ]) ++ (optionals cfg.block.gambling [
            "127.0.0.0/8 block-gambling"
            "::1 block-gambling"
          ]) ++ (optionals cfg.block.porn [
            "127.0.0.0/8 block-porn"
            "::1 block-porn"
          ]) ++ (optionals cfg.block.social [
            "127.0.0.0/8 block-social"
            "::1 block-social"
          ]);

          log-replies = cfg.log.enable;
          log-local-actions = cfg.log.enable;
          log-servfail = cfg.log.enable;
        };

        include = [
          "${pkgs.hosts}/unbound/block-ad.conf"
          "${pkgs.hosts}/unbound/block-fakenews.conf"
          "${pkgs.hosts}/unbound/block-gambling.conf"
          "${pkgs.hosts}/unbound/block-porn.conf"
          "${pkgs.hosts}/unbound/block-social.conf"
        ];
      };
    };

    services.smartdns = {
      enable = true;
      settings = {
        bind = [ "[::1]:54" ];
        server = [
          "[::1]:55 -group global gfwlist"

          # dns.sb
          "185.222.222.222 -group global -exclude-default-group"
          "[2a09::] -group global -exclude-default-group"

          # Tsinghua
          "101.6.6.6:5353 -group china -exclude-default-group"

          # USTC
          "202.38.93.153:5353 -group china -exclude-default-group"
          "202.141.162.123:5353 -group china -exclude-default-group"
          "202.141.178.13:5353 -group china -exclude-default-group"
        ];
        server-tls = [
          # cloudflare-dns.com
          "1.1.1.1:853 -group global gfwlist"
          "[2606:4700:4700::1111]:853 -group global gfwlist"

          # quad9.net
          "9.9.9.9:853 -group global gfwlist"
          "149.112.112.112:853 -group global gfwlist"
          "[2620:fe::fe]:853 -group global gfwlist"

          # dns.sb
          "185.222.222.222:853 -group global gfwlist"
          "[2a09::]:853 -group global gfwlist"

          # alidns.com
          "223.5.5.5:853 -group china -exclude-default-group"

          # dns.pub
          "119.29.29.29:853 -group china -exclude-default-group"
        ];
        server-https = [
          "https://cloudflare-dns.com/dns-query -group global gfwlist"
          "https://doh.opendns.com/dns-query -group global gfwlist"
          "https://dns.tuna.tsinghua.edu.cn:8443/resolve -group china -exclude-default-group"
        ];
        cache-size = 0;
        cache-persist = false;
        speed-check-mode = mkDefault "none";
        prefetch-domain = mkDefault false;
        serve-expired = mkDefault true;
        force-AAAA-SOA = cfg.block.ipv6;
        dualstack-ip-selection = mkDefault false;
        log-level = mkDefault "warn";
        nameserver = [
          "/xqzp.net/china"
        ];
        conf-file = optionals cfg.chinalist.enable [
          "${pkgs.chinalist-smartdns}/accelerated-domains.china.smartdns.conf"
          "${pkgs.chinalist-smartdns}/apple.china.smartdns.conf"
          "${pkgs.chinalist-smartdns}/google.china.smartdns.conf"
        ] ++ optionals (cfg.chinalist.enable && cfg.ipset.enable) [
          "${pkgs.chinalist-smartdns}/accelerated-domains.china.smartdns.ipset.conf"
          "${pkgs.chinalist-smartdns}/apple.china.smartdns.ipset.conf"
          "${pkgs.chinalist-smartdns}/google.china.smartdns.ipset.conf"
        ] ++ optionals cfg.gfwlist.enable [
          "${pkgs.gfwlist-smartdns}/gfwlist.smartdns.conf"
        ] ++ optionals (cfg.gfwlist.enable && cfg.ipset.enable) [
          "${pkgs.gfwlist-smartdns}/gfwlist.smartdns.ipset.conf"
        ];
      };
    };

    systemd.services.smartdns = mkIf cfg.ipset.enable {
      path = [ pkgs.ipset ];
      preStart = ''
        ipset create -exist china4 hash:ip family inet
        ipset create -exist china6 hash:ip family inet6
        ipset create -exist gfwlist4 hash:ip family inet
        ipset create -exist gfwlist6 hash:ip family inet6
      '';
      postStop = ''
        ipset flush china4
        ipset flush china6
        ipset flush gfwlist4
        ipset flush gfwlist6
      '';
    };

    services.dnscrypt-proxy2 = {
      enable = true;
      settings = {
        listen_addresses = [ "[::1]:55" ];
        fallback_resolvers = [
          "1.1.1.1:53"
          "8.8.8.8:53"
          "9.9.9.9:53"
          "114.114.114.114:53"
        ];
        ipv6_servers = true;
        cache = false;
      };
    };
  };
}
