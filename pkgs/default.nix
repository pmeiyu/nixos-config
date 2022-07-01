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
  chinalist-routedns = callPackage ./dnsmasq-china-list.nix {
    format = "routedns";
  };
  gfwlist = callPackage ./gfwlist.nix { format = "raw"; };
  gfwlist-dnsmasq = callPackage ./gfwlist.nix {
    format = "dnsmasq";
    enable-nftset = true;
  };
  gfwlist-routedns = callPackage ./gfwlist.nix {
    format = "routedns";
  };
  hosts = callPackage ./hosts.nix { };
  kcptun = callPackage ./kcptun.nix { };
  udpspeeder = callPackage ./udpspeeder.nix { };
  vlmcsd = callPackage ./vlmcsd.nix { };
}
