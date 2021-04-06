{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.hotspot;
in
{
  options = {
    my.hotspot = {
      enable = mkEnableOption "Enable WiFi hotspot.";
      version = mkOption {
        type = types.enum [ 4 5 6 ];
        default = 4;
        description = "WiFi version.";
      };
      interface = mkOption {
        type = types.str;
        default = "wlan0";
        description = "Network interface.";
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
      ssid = mkOption {
        type = types.str;
        description = "SSID.";
      };
      password = mkOption {
        type = types.str;
        description = "WPA password.";
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
        ht_capab=[HT40+][SHORT-GI-20][SHORT-GI-40][DSSS_CCK-40]
      '') + (optionalString (cfg.version == 5) ''
        ieee80211ac=1
        ieee80211n=1
        vht_capab=[SHORT-GI-80][HTC-VHT]
      '') + (optionalString (cfg.version == 6) ''
        ieee80211ax=1
      '');
    };

    services.dhcpd4 = {
      enable = true;
      interfaces = [ "wlan0" ];
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
        interface wlan0 {
          AdvSendAdvert on;
          prefix fd00:10::/64 { };
        };
      '';
    };

    networking.networkmanager.unmanaged = [ cfg.interface ];
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

    services.unbound = {
      interfaces = [ "10.10.0.1" ];
      allowedAccess = [ "10.10.0.0/16" "fd00:10::/64" ];
      extraConfig = ''
        server:

        ${optionalString cfg.block.ad ''
          access-control-view: 10.10.0.0/16 block-ad
          access-control-view: fd00:10::/64 block-ad
        ''}

        ${optionalString cfg.block.fake-news ''
          access-control-view: 10.10.0.0/16 block-fakenews
          access-control-view: fd00:10::/64 block-fakenews
        ''}

        ${optionalString cfg.block.gambling ''
          access-control-view: 10.10.0.0/16 block-gambling
          access-control-view: fd00:10::/64 block-gambling
        ''}

        ${optionalString cfg.block.porn ''
          access-control-view: 10.10.0.0/16 block-porn
          access-control-view: fd00:10::/64 block-porn
        ''}

        ${optionalString cfg.block.social ''
          access-control-view: 10.10.0.0/16 block-social
          access-control-view: fd00:10::/64 block-social
        ''}
      '';
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
