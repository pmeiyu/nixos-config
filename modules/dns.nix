{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.dns;
in {
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

    services.unbound = {
      enable = true;
      interfaces = [ "127.0.0.1@53" "::1@53" ];
      allowedAccess = [ ];
      forwardAddresses = [ ];
      enableRootTrustAnchor = cfg.dnssec.enable;
      extraConfig = ''
        server:
        cache-min-ttl: 600
        cache-max-negative-ttl: 60
        do-not-query-localhost: no

        domain-insecure: "home"
        domain-insecure: "lan"
        domain-insecure: "tinc"
        private-domain: "home"
        private-domain: "lan"
        private-domain: "tinc"
        private-address: 10.0.0.0/8
        private-address: 169.254.0.0/16
        private-address: 172.16.0.0/12
        private-address: 192.168.0.0/16
        private-address: fd00::/8
        private-address: fe80::/10

        ${optionalString cfg.block.ad ''
          access-control-view: 127.0.0.0/8 block-ad
          access-control-view: ::1 block-ad
        ''}

        ${optionalString cfg.block.fake-news ''
          access-control-view: 127.0.0.0/8 block-fakenews
          access-control-view: ::1 block-fakenews
        ''}

        ${optionalString cfg.block.gambling ''
          access-control-view: 127.0.0.0/8 block-gambling
          access-control-view: ::1 block-gambling
        ''}

        ${optionalString cfg.block.porn ''
          access-control-view: 127.0.0.0/8 block-porn
          access-control-view: ::1 block-porn
        ''}

        ${optionalString cfg.block.social ''
          access-control-view: 127.0.0.0/8 block-social
          access-control-view: ::1 block-social
        ''}

        include: ${pkgs.hosts}/unbound/block-ad.conf
        include: ${pkgs.hosts}/unbound/block-fakenews.conf
        include: ${pkgs.hosts}/unbound/block-gambling.conf
        include: ${pkgs.hosts}/unbound/block-porn.conf
        include: ${pkgs.hosts}/unbound/block-social.conf

        forward-zone:
          name: .
            forward-addr: ::1@54
      '';
    };

    services.smartdns = {
      enable = true;
      settings = {
        bind = [ "[::1]:54" ];
        server = [
          # Tsinghua
          "101.6.6.6:5353 -group china -exclude-default-group"
          # USTC
          "202.38.93.153:5353 -group china -exclude-default-group"
          "202.141.162.123:5353 -group china -exclude-default-group"
          "202.141.178.13:5353 -group china -exclude-default-group"
        ];
        server-tls = [
          "1.1.1.1:853 -group global gfwlist"
          "8.8.8.8:853 -group global gfwlist"
          "9.9.9.9:853 -group global gfwlist"
          # alidns.com
          "223.5.5.5:853 -group china -exclude-default-group"
          # dns.pub
          "119.29.29.29:853 -group china -exclude-default-group"
          # dns.sb
          "185.222.222.222:853 -group global"
        ];
        server-https = [
          "https://cloudflare-dns.com/dns-query -group global gfwlist -exclude-default-group"
          "https://dns.tuna.tsinghua.edu.cn:8443/resolve -group china -exclude-default-group"
        ];
        speed-check-mode = mkDefault "ping,tcp:80";
        prefetch-domain = mkDefault false;
        serve-expired = mkDefault true;
        force-AAAA-SOA = cfg.block.ipv6;
        dualstack-ip-selection = mkDefault (!cfg.block.ipv6);
        log-level = mkDefault "warn";
        audit-enable = mkDefault cfg.log.enable;
        conf-file = optionals cfg.chinalist.enable [
          "${pkgs.chinalist-smartdns}/accelerated-domains.china.smartdns.conf"
          "${pkgs.chinalist-smartdns}/apple.china.smartdns.conf"
          "${pkgs.chinalist-smartdns}/google.china.smartdns.conf"
        ] ++ optionals (cfg.chinalist.enable && cfg.ipset.enable) [
          "${pkgs.chinalist-smartdns}/accelerated-domains.china.smartdns.ipset.conf"
          "${pkgs.chinalist-smartdns}/apple.china.smartdns.ipset.conf"
          "${pkgs.chinalist-smartdns}/google.china.smartdns.ipset.conf"
        ] ++ optionals cfg.gfwlist.enable
          [ "${pkgs.gfwlist-smartdns}/gfwlist.smartdns.conf" ]
          ++ optionals (cfg.gfwlist.enable && cfg.ipset.enable)
          [ "${pkgs.gfwlist-smartdns}/gfwlist.smartdns.ipset.conf" ];
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
  };
}
