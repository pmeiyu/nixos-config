{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.tun2socks;
in
{
  options = {
    my.tun2socks = {
      enable = mkEnableOption "Enable tun2socks.";
      interface = mkOption {
        type = types.str;
        default = "tun-socks";
        description = "Network interface name";
      };
      socks-proxy = mkOption {
        type = types.str;
        default = "127.0.0.1:1080";
        description = "SOCKS proxy";
      };
      udp = {
        enable = mkEnableOption "Enable UDP";
        gateway = mkOption {
          type = types.str;
          default = "127.0.0.1:7300";
          description = "badvpn-udpgw address";
        };
      };
      routes4 = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "IPv4 routes";
      };
      routes6 = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "IPv6 routes";
      };
      ipset4 = mkOption {
        type = types.str;
        default = "tun2socks4";
        description = "Route IPv4 addresses in this ipset";
      };
      ipset6 = mkOption {
        type = types.str;
        default = "tun2socks6";
        description = "Route IPv6 addresses in this ipset";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.checkReversePath = "loose";

    systemd.services.tun2socks = {
      description = "tun2socks";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.iproute pkgs.nftables ];
      preStart = ''
        ip tuntap del dev ${cfg.interface} mode tun
        ip tuntap add dev ${cfg.interface} mode tun
        ip address add 10.8.8.2/24 dev ${cfg.interface}
        ip address add fd00:8:8::2/24 dev ${cfg.interface}
        ip link set dev ${cfg.interface} up
      '';
      serviceConfig = {
        ExecStart = "${pkgs.badvpn}/bin/badvpn-tun2socks"
          + " --tundev ${cfg.interface}" + " --netif-ipaddr 10.8.8.1"
          + " --netif-netmask 255.255.255.0" + " --netif-ip6addr fd00:8:8::1"
          + " --socks-server-addr ${cfg.socks-proxy}"
          + (optionalString cfg.udp.enable
          " --udpgw-remote-server-addr ${cfg.udp.gateway}");
      };
      postStart = ''
        TABLE=110
        INTERFACE=${cfg.interface}

        ROUTES4="${concatStringsSep "\n" cfg.routes4}"
        ROUTES6="${concatStringsSep "\n" cfg.routes6}"

        ip rule add from all lookup $TABLE priority $TABLE
        ip -6 rule add from all lookup $TABLE priority $TABLE

        for i in $ROUTES4; do
          ip route replace $i dev $INTERFACE table $TABLE
        done

        for i in $ROUTES6; do
          ip -6 route replace $i dev $INTERFACE table $TABLE
        done


        ## IPSET

        ipset create -exist ${cfg.ipset4} hash:ip family inet
        ipset create -exist ${cfg.ipset6} hash:ip family inet6

        iptables -t mangle -I PREROUTING -m set --match-set ${cfg.ipset4} dst -j MARK --set-mark 111
        ip6tables -t mangle -I PREROUTING -m set --match-set ${cfg.ipset6} dst -j MARK --set-mark 111
        iptables -t mangle -I OUTPUT -m set --match-set ${cfg.ipset4} dst -j MARK --set-mark 111
        ip6tables -t mangle -I OUTPUT -m set --match-set ${cfg.ipset6} dst -j MARK --set-mark 111

        ip rule add fwmark 111 lookup 111 priority 111
        ip -6 rule add fwmark 111 lookup 111 priority 111

        ip route replace default dev $INTERFACE table 111
        ip -6 route replace default dev $INTERFACE table 111
      '';
      postStop = ''
        ip rule delete from all lookup 110 priority 110 || true
        ip -6 rule delete from all lookup 110 priority 110 || true

        iptables -t mangle -D PREROUTING -m set --match-set ${cfg.ipset4} dst -j MARK --set-mark 111 || true
        ip6tables -t mangle -D PREROUTING -m set --match-set ${cfg.ipset6} dst -j MARK --set-mark 111 || true
        iptables -t mangle -D OUTPUT -m set --match-set ${cfg.ipset4} dst -j MARK --set-mark 111
        ip6tables -t mangle -D OUTPUT -m set --match-set ${cfg.ipset6} dst -j MARK --set-mark 111

        ip rule delete fwmark 111 lookup 111 priority 111 || true
        ip -6 rule delete fwmark 111 lookup 111 priority 111 || true

        ip tuntap del dev ${cfg.interface} mode tun
      '';
    };
  };
}
