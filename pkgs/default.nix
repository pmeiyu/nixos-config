{ pkgs ? import <nixpkgs> { } }:

with pkgs; {
  data = import ./data;
  chinalist = callPackage ./dnsmasq-china-list.nix { format = "raw"; };
  chinalist-smartdns = callPackage ./dnsmasq-china-list.nix {
    format = "smartdns";
    upstream-dns = "china";
    ipset = true;
  };
  gfwlist = callPackage ./gfwlist.nix { format = "raw"; };
  gfwlist-smartdns = callPackage ./gfwlist.nix { format = "smartdns"; };
  go-shadowsocks2 = callPackage ./go-shadowsocks2.nix { };
  gost = callPackage ./gost.nix { };
  hosts = callPackage ./hosts.nix { };
  kcptun = callPackage ./kcptun.nix { };
  udpspeeder = callPackage ./udpspeeder.nix { };
  v2ray-plugin = callPackage ./v2ray-plugin.nix { };
  vlmcsd = callPackage ./vlmcsd.nix { };
}
