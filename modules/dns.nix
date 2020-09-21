{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.dns;
in {
  options = {
    my.dns = {
      enable = mkEnableOption "Enable local DNS server.";
      dnssec.enable = mkEnableOption "Enable DNSSEC.";
      tcp-upstream = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether the upstream queries use TCP only for transport.
        '';
      };
      block.ad = mkEnableOption "Block ad.";
      block.fake-news = mkEnableOption "Block fake news.";
      block.gambling = mkEnableOption "Block gambling.";
      block.social = mkEnableOption "Block social networks.";
      dnsmasq-china-list.enable = mkEnableOption "Enable dnsmasq-china-list.";
      ipset.enable = mkEnableOption "Enable ipset.";
    };
  };

  config = mkIf cfg.enable {
    networking.nameservers = [ "::1" ];
    networking.networkmanager.dns = mkDefault "none";

    services.dnscrypt-proxy2 = {
      enable = true;
      settings = {
        listen_addresses = [ "[::1]:54" ];
        require_dnssec = cfg.dnssec.enable;
        require_nolog = true;
        require_nofilter = true;
        force_tcp = cfg.tcp-upstream;
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
        RestartSec = "120";
      };
    };

    services.unbound = {
      enable = true;
      interfaces = [ "127.0.0.1@55" "::1@55" ];
      allowedAccess = [ ];
      forwardAddresses = [ ];
      enableRootTrustAnchor = cfg.dnssec.enable;
      extraConfig = ''
        cache-min-ttl: 600
        cache-max-negative-ttl: 3
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

        ${optionalString cfg.tcp-upstream ''
          tcp-upstream: yes
        ''}

        ${optionalString cfg.block.ad ''
          access-control-view: 0.0.0.0 block-ad
          access-control-view: :: block-ad
          include: ${pkgs.steven-black-hosts}/unbound/ad.conf
        ''}

        ${optionalString cfg.block.fake-news ''
          access-control-view: 0.0.0.0 block-fakenews
          access-control-view: :: block-fakenews
          include: ${pkgs.steven-black-hosts}/unbound/fakenews.conf
        ''}

        ${optionalString cfg.block.gambling ''
          access-control-view: 0.0.0.0 block-gambling
          access-control-view: :: block-gambling
          include: ${pkgs.steven-black-hosts}/unbound/gambling.conf
        ''}

        ${optionalString cfg.block.social ''
          access-control-view: 0.0.0.0 block-social
          access-control-view: :: block-social
          include: ${pkgs.steven-black-hosts}/unbound/social.conf
        ''}

        ${optionalString cfg.dnsmasq-china-list.enable ''
          include: ${pkgs.dnsmasq-china-list}/unbound/*.conf
        ''}

        forward-zone:
          name: .
          forward-addr: ::1@54
      '';
    };

    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      extraConfig = ''
        except-interface=virbr0
        bind-dynamic

        server=::1#55

        no-resolv
        log-queries
        log-dhcp
        cache-size=1000
        min-cache-ttl=600
        local=/lan/
        domain=lan
        expand-hosts

        addn-hosts=/etc/hosts.local

        ${optionalString cfg.ipset.enable ''
          conf-dir=${pkgs.dnsmasq-china-list}/dnsmasq-ipset/,*.conf
          conf-dir=${pkgs.gfwlist}/dnsmasq-ipset/,*.conf
        ''}
      '';
    };

    systemd.services.dnsmasq = {
      path = [ pkgs.ipset ];
      preStart = optionalString cfg.ipset.enable ''
        ipset create -exist china4 hash:ip family inet
        ipset create -exist china6 hash:ip family inet6
        ipset create -exist gfwlist4 hash:ip family inet
        ipset create -exist gfwlist6 hash:ip family inet6
      '';
    };
  };
}
