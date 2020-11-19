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
          Whether to query upstream with TCP.
        '';
      };
      block.ipv6 = mkEnableOption "Do not resolve IPv6 record.";
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
        block_ipv6 = cfg.block.ipv6;
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
      interfaces = [ "127.0.0.1@53" "::1@53" ];
      allowedAccess = [ ];
      forwardAddresses = [ ];
      enableRootTrustAnchor = cfg.dnssec.enable;
      extraConfig = ''
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

        ${optionalString cfg.tcp-upstream ''
          tcp-upstream: yes
        ''}

        ${optionalString cfg.block.ad ''
          access-control-view: 127.0.0.0/8 block-ad
          access-control-view: ::/8 block-ad
          include: ${pkgs.hosts}/unbound/block-ad.conf
        ''}

        ${optionalString cfg.block.fake-news ''
          access-control-view: 127.0.0.0/8 block-fakenews
          access-control-view: ::/8 block-fakenews
          include: ${pkgs.hosts}/unbound/block-fakenews.conf
        ''}

        ${optionalString cfg.block.gambling ''
          access-control-view: 127.0.0.0/8 block-gambling
          access-control-view: ::/8 block-gambling
          include: ${pkgs.hosts}/unbound/block-gambling.conf
        ''}

        ${optionalString cfg.block.social ''
          access-control-view: 127.0.0.0/8 block-social
          access-control-view: ::/8 block-social
          include: ${pkgs.hosts}/unbound/block-social.conf
        ''}

        forward-zone:
          name: .
          forward-addr: ::1@55
      '';
    };

    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = false;
      extraConfig = ''
        port=55
        except-interface=virbr0
        bind-dynamic

        server=::1#54

        no-resolv
        log-queries
        log-dhcp
        local=/lan/
        domain=lan
        expand-hosts

        # Disable cache
        cache-size=0
        min-cache-ttl=0

        addn-hosts=/etc/hosts.local

        ${optionalString cfg.dnsmasq-china-list.enable ''
          conf-dir=${pkgs.dnsmasq-china-list}/dnsmasq/,*.conf
        ''}

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
      postStop = optionalString cfg.ipset.enable ''
        ipset flush china4
        ipset flush china6
        ipset flush gfwlist4
        ipset flush gfwlist6
      '';
    };
  };
}
