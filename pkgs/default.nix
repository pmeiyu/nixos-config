{ pkgs ? import <nixpkgs> { }
, mypkgs ? import (builtins.fetchTarball "https://github.com/pmeiyu/nixpkgs/archive/master.tar.gz") { }
}:

with pkgs; {
  mypkgs = mypkgs;
  data = callPackage ./data { };
  chinalist = callPackage ./dnsmasq-china-list.nix { format = "raw"; };
  chinalist-dnsmasq = callPackage ./dnsmasq-china-list.nix {
    format = "dnsmasq";
    enable-nftset = true;
  };
  chinalist-smartdns = callPackage ./dnsmasq-china-list.nix {
    format = "smartdns";
    upstream-dns = "china";
  };
  gfwlist = callPackage ./gfwlist.nix { format = "raw"; };
  gfwlist-dnsmasq = callPackage ./gfwlist.nix {
    format = "dnsmasq";
    enable-nftset = true;
  };
  gfwlist-smartdns = callPackage ./gfwlist.nix {
    format = "smartdns";
  };
  go-shadowsocks2 = callPackage ./go-shadowsocks2.nix { };
  gost = callPackage ./gost.nix { };
  hosts = callPackage ./hosts.nix { };
  kcptun = callPackage ./kcptun.nix { };
  udpspeeder = callPackage ./udpspeeder.nix { };
  vlmcsd = callPackage ./vlmcsd.nix { };
}
