let pkgs = import <nixpkgs> { };
in with pkgs; {
  data = import ./data;
  dnsmasq-china-list = callPackage ./dnsmasq-china-list.nix { };
  gfwlist = callPackage ./gfwlist.nix { };
  go-shadowsocks2 = callPackage ./go-shadowsocks2.nix { };
  gost = callPackage ./gost.nix { };
  ibus-engines.rime = callPackage ./ibus-rime.nix { };
  kcptun = callPackage ./kcptun.nix { };
  steven-black-hosts = callPackage ./steven-black-hosts.nix { };
  udpspeeder = callPackage ./udpspeeder.nix { };
  v2ray-plugin = callPackage ./v2ray-plugin.nix { };
  vlmcsd = callPackage ./vlmcsd.nix { };
}
