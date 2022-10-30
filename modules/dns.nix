{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.dns;
  enable-garbage-blocker = any id (attrValues cfg.block);
  processors = [
    "main"
    "router"
  ]
  ++ optionals enable-garbage-blocker [ "block-garbage" ]
  ++ [
    "block-dotless-domains"
    "block-special-domains"
    "block-private-ip-p"
    "block-private-ip"
  ]
  ++ optionals cfg.probe.enable [ "tcp-probe" ]
  ++ optionals cfg.chinalist.enable [ "chinalist" ]
  ++ optionals cfg.gfwlist.enable [ "gfwlist" ]
  ++ [ "default-resolvers" ];
  nextProcessorMap = listToAttrs
    (map (i: { name = elemAt processors i; value = elemAt processors (i + 1); })
      (genList id ((length processors) - 1)));
  nextProcessorOf = x: getAttr x nextProcessorMap;
in
{
  options = {
    my.dns = {
      enable = mkEnableOption "DNS server.";
      block.ad = mkEnableOption "Block ad.";
      block.fake-news = mkEnableOption "Block fake news.";
      block.gambling = mkEnableOption "Block gambling.";
      block.porn = mkEnableOption "Block porn.";
      block.social = mkEnableOption "Block social networks.";
      block.ipv6 = mkEnableOption "Block IPv6 (AAAA) records";
      probe.enable = mkEnableOption "Probe A/AAAA records and return record for the fastest response";
      probe.port = mkOption {
        type = types.int;
        default = 443;
        description = "TCP port";
      };
      chinalist.enable = mkEnableOption "Enable dnsmasq-china-list.";
      gfwlist.enable = mkEnableOption "Enable gfwlist.";
      log.enable = mkEnableOption "Enable log.";
    };
  };

  config = mkIf cfg.enable {
    networking.nameservers = [ "::1" ];
    networking.networkmanager.dns = mkDefault "none";

    services.nginx.resolver.addresses = [ "[::1]" ];

    services.routedns = {
      enable = true;
      settings = {
        listeners = {
          local = {
            address = "127.0.0.1:53";
            protocol = "udp";
            resolver = "main";
          };
          local-ipv6 = {
            address = "[::1]:53";
            protocol = "udp";
            resolver = "main";
          };
        };
        groups = {
          main = {
            type = "cache";
            resolvers = [ (nextProcessorOf "main") ];
          };

          block-garbage = mkIf enable-garbage-blocker {
            type = "blocklist-v2";
            resolvers = [ (nextProcessorOf "block-garbage") ];
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

          block-dotless-domains = {
            type = "blocklist-v2";
            resolvers = [ (nextProcessorOf "block-dotless-domains") ];
            blocklist = [ "^[^.]+$" ];
          };

          block-special-domains = {
            type = "blocklist-v2";
            resolvers = [ (nextProcessorOf "block-special-domains") ];
            blocklist-format = "domain";
            blocklist = map (x: "." + x)
              (pkgs.data.domain.special-top-level-domains ++ pkgs.data.domain.local-dns-zones);
          };

          block-private-ip-p = {
            type = "blocklist-v2";
            resolvers = [ "block-private-ip" ];
            allowlist-resolver = nextProcessorOf "block-private-ip";
            allowlist-format = "domain";
            allowlist = [
              ".xqzp.net"
            ];
            blocklist-format = "domain";
            blocklist = [
              "*.home"
              "*.lan"
              "*.local"
            ];
          };

          block-private-ip = {
            type = "response-blocklist-ip";
            resolvers = [ (nextProcessorOf "block-private-ip") ];
            blocklist = pkgs.data.ip.v4.private ++ pkgs.data.ip.v6.private;
          };

          tcp-probe = mkIf cfg.probe.enable {
            type = "fastest-tcp";
            port = cfg.probe.port;
            success-ttl-min = 3600;
            resolvers = [ (nextProcessorOf "tcp-probe") ];
          };

          chinalist = mkIf cfg.chinalist.enable {
            type = "blocklist-v2";
            resolvers = [ (nextProcessorOf "chinalist") ];
            allowlist-resolver = "china-resolvers";
            allowlist-source = [
              { format = "domain"; source = "${pkgs.chinalist-routedns}/accelerated-domains.china.routedns.txt"; }
              { format = "domain"; source = "${pkgs.chinalist-routedns}/apple.china.routedns.txt"; }
            ];
            blocklist-resolver = "114";
            blocklist-source = [
              { format = "domain"; source = "${pkgs.chinalist-routedns}/google.china.routedns.txt"; }
            ];
          };

          gfwlist = mkIf cfg.gfwlist.enable {
            type = "blocklist-v2";
            resolvers = [ (nextProcessorOf "gfwlist") ];
            blocklist-resolver = "global-resolvers";
            blocklist-source = optionals cfg.gfwlist.enable [
              { format = "domain"; source = "${pkgs.gfwlist-routedns}/gfwlist.routedns.txt"; }
            ];
          };

          default-resolvers = {
            type = "random";
            resolvers = [
              "dnscrypt-proxy"

              "cloudflare-http"
              "cloudflare-tls"
              "cloudflare-tls-ipv6"
              "dns-sb-tls"
              "dns-sb-tls-ipv6"
              "opendns-http"
              "opendns-tls"
              "quad9-tls"
              "quad9-tls-2"
              "quad9-tls-ipv6"
            ];
          };

          china-resolvers = {
            type = "random";
            resolvers = [
              "alidns"
              "alidns-tls"
              "baidu"
              "dns-pub-ipv6"
              "dns-pub-http"
              "dns-pub-tls"
              "tsinghua"
              "tsinghua-http"
            ];
          };

          global-resolvers = {
            type = "random";
            resolvers = [
              "dnscrypt-proxy"

              "cloudflare-http"
              "cloudflare-tls"
              "cloudflare-tls-ipv6"
              "dns-sb-tls"
              "dns-sb-tls-ipv6"
              "opendns-http"
              "opendns-tls"
              "quad9-tls"
              "quad9-tls-2"
              "quad9-tls-ipv6"
            ];
          };

          block = {
            type = "static-responder";
            rcode = 0;
          };

          refuse = {
            type = "static-responder";
            rcode = 5;
          };

          drop = {
            type = "drop";
          };
        };

        routers = {
          router = {
            routes = mkAfter ((optional cfg.block.ipv6 { types = [ "AAAA" ]; resolver = "block"; })
              ++ [{ resolver = (nextProcessorOf "router"); }]);
          };
        };

        resolvers = {
          dnscrypt-proxy = {
            address = "[::1]:54";
            protocol = "udp";
          };

          cloudflare-http = {
            address = "https://cloudflare-dns.com/dns-query";
            protocol = "doh";
            transport = "quic";
          };
          cloudflare-tls = {
            address = "1.1.1.1:853";
            protocol = "dot";
          };
          cloudflare-tls-ipv6 = {
            address = "[2606:4700:4700::1111]:853";
            protocol = "dot";
          };

          dns-sb-tls = {
            address = "dot.sb:853";
            bootstrap-address = "185.222.222.222";
            protocol = "dot";
          };
          dns-sb-tls-ipv6 = {
            address = "dot.sb:853";
            bootstrap-address = "2a09::";
            protocol = "dot";
          };

          google = {
            address = "8.8.8.8:53";
            protocol = "udp";
          };
          google-http = {
            address = "https://dns.google/dns-query";
            bootstrap-address = "8.8.8.8";
            protocol = "doh";
          };
          google-tls = {
            address = "dns.google:853";
            bootstrap-address = "8.8.8.8";
            protocol = "dot";
          };

          opendns-http = {
            address = "https://doh.opendns.com/dns-query";
            protocol = "doh";
          };
          opendns-tls = {
            address = "208.67.222.222:853";
            protocol = "dot";
          };

          quad9-tls = {
            address = "9.9.9.9:853";
            protocol = "dot";
          };
          quad9-tls-2 = {
            address = "149.112.112.112:853";
            protocol = "dot";
          };
          quad9-tls-ipv6 = {
            address = "[2620:fe::fe]:853";
            protocol = "dot";
          };


          "114" = {
            address = "114.114.114.114:53";
            protocol = "udp";
          };

          alidns = {
            address = "223.5.5.5:53";
            protocol = "udp";
          };
          alidns-tls = {
            address = "dns.alidns.com:853";
            protocol = "dot";
          };

          baidu = {
            address = "180.76.76.76:53";
            protocol = "udp";
          };

          dns-pub-ipv6 = {
            address = "[2402:4e00::]:53";
            protocol = "udp";
          };
          dns-pub-http = {
            address = "https://doh.pub/dns-query";
            protocol = "doh";
          };
          dns-pub-tls = {
            address = "1.12.12.12:853";
            protocol = "dot";
          };

          tsinghua = {
            address = "101.6.6.6:5353";
            protocol = "udp";
          };
          tsinghua-http = {
            address = "https://dns.tuna.tsinghua.edu.cn:8443/resolve";
            protocol = "doh";
          };
        };
      };
    };
    systemd.services.routedns = {
      wantedBy = [ "network-online.target" ];
    };

    services.dnscrypt-proxy2 = {
      enable = true;
      settings = {
        listen_addresses = [ "[::1]:54" ];
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
