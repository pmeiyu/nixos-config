{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.hotspot;
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
        description = "WPA password.";
      };
      version = mkOption {
        type = types.enum [ 4 5 6 ];
        default = 4;
        description = "WiFi version.";
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
      ht_capab = mkOption {
        type = types.str;
        default = "";
        example = "[HT40+][SHORT-GI-40]";
      };
      vht_capab = mkOption {
        type = types.str;
        default = "";
        example = "[SHORT-GI-80][HTC-VHT]";
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
      interface = cfg.interface;
      ssid = cfg.ssid;
      hwMode = if cfg.version == 4 then "g" else "a";
      channel = cfg.channel;
      countryCode = cfg.countryCode;
      wpaPassphrase = cfg.password;
      extraConfig = ''
        utf8_ssid=1

        # 1 = WPA, 2 = WEP, 3 = both
        auth_algs=1

        # WPA-PSK = WPA-Personal / WPA2-Personal
        # SAE = WPA3-Personal
        wpa_key_mgmt=WPA-PSK

        # CCMP = AES in Counter mode with CBC-MAC (CCMP-128)
        rsn_pairwise=CCMP

        # QoS
        wmm_enabled=1

      '' + (optionalString (cfg.version == 4) ''
        ieee80211n=1
        ht_capab=${cfg.ht_capab}
      '') + (optionalString (cfg.version == 5) ''
        ieee80211ac=1
        ieee80211n=1
        vht_capab=${cfg.vht_capab}
      '') + (optionalString (cfg.version == 6) ''
        ieee80211ax=1
      '');
    };

    services.dhcpd4 = {
      enable = true;
      interfaces = [ cfg.interface ];
      extraConfig = ''
        option domain-name-servers 10.10.0.1;
        option domain-name "lan";
        option routers 10.10.0.1;
        option subnet-mask 255.255.255.0;
        subnet 10.10.0.0 netmask 255.255.255.0 {
          range 10.10.0.10 10.10.0.100;
        }
      '';
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

    services.unbound.settings = {
      server = {
        interface = [
          "10.10.0.1"
          "fd00:10::1"
        ];
        access-control = [
          "10.10.0.0/16 allow"
          "fd00:10::/64 allow"
        ];
        access-control-view = [
        ] ++ (optionals cfg.block.ad [
          "10.10.0.0/16 block-ad"
          "fd00:10::/64 block-ad"
        ]) ++ (optionals cfg.block.fake-news [
          "10.10.0.0/16 block-fakenews"
          "fd00:10::/64 block-fakenews"
        ]) ++ (optionals cfg.block.gambling [
          "10.10.0.0/16 block-gambling"
          "fd00:10::/64 block-gambling"
        ]) ++ (optionals cfg.block.porn [
          "10.10.0.0/16 block-porn"
          "fd00:10::/64 block-porn"
        ]) ++ (optionals cfg.block.social [
          "10.10.0.0/16 block-social"
          "fd00:10::/64 block-social"
        ]);
      };
    };

    networking.firewall = {
      interfaces."${cfg.interface}" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
      extraCommands = ''
        # Hijack DNS requests.
        iptables -w -t nat -A PREROUTING -s 10.10.0.0/24 ! -d 10.10.0.1 -p udp --dport 53 -j DNAT --to 127.0.0.1:53
        iptables -w -t nat -A PREROUTING -s 10.10.0.0/24 ! -d 10.10.0.1 -p tcp --dport 53 -j DNAT --to 127.0.0.1:53

        iptables -w -t nat -A POSTROUTING -s 10.10.0.0/24 -j MASQUERADE
        iptables -w -A FORWARD -i ${cfg.interface} -s 10.10.0.0/24 -j ACCEPT
        iptables -w -A FORWARD -o ${cfg.interface} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      '';
      extraStopCommands = ''
        iptables -w -t nat -D PREROUTING -s 10.10.0.0/24 ! -d 10.10.0.1 -p udp --dport 53 -j DNAT --to 127.0.0.1:53
        iptables -w -t nat -D PREROUTING -s 10.10.0.0/24 ! -d 10.10.0.1 -p tcp --dport 53 -j DNAT --to 127.0.0.1:53

        iptables -w -t nat -D POSTROUTING -s 10.10.0.0/24 -j MASQUERADE
        iptables -w -D FORWARD -i ${cfg.interface} -s 10.10.0.0/24 -j ACCEPT
        iptables -w -D FORWARD -o ${cfg.interface} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      '';
    };
  };
}
