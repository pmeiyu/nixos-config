{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.hotspot;
in {
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
    };
  };

  config = mkIf cfg.enable {
    services.hostapd = {
      enable = true;
      interface = cfg.interface;
      ssid = cfg.ssid;
      hwMode = "a";
      channel = 40;
      countryCode = "US";
      wpaPassphrase = cfg.password;
      extraConfig = ''
        ieee80211ac=1

        # QoS
        wmm_enabled=1

        # 1 = WPA
        auth_algs=1

        # WPA-PSK = WPA-Personal
        # SAE = WPA3-Personal
        wpa_key_mgmt=WPA-PSK

        # CCMP = AES in Counter mode with CBC-MAC (CCMP-128)
        rsn_pairwise=CCMP
      '';
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

    # services.unbound = {
    #   interfaces = [ "10.10.0.1" ];
    #   allowedAccess = [ "10.10.0.0/16" "fd00:10::/64" ];
    # };

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

    networking.nat = {
      enable = true;
      internalIPs = [ "10.10.0.0/24" ];
    };
  };
}
