let pkgs = import <nixpkgs> { };
in with pkgs; {
  dnsmasq-china-list = {
    dnscrypt-proxy =
      callPackage ./dnsmasq-china-list.nix { target = "dnscrypt-proxy"; };
    dnsmasq = callPackage ./dnsmasq-china-list.nix { target = "dnsmasq"; };
    raw = callPackage ./dnsmasq-china-list.nix { target = "raw"; };
    unbound = callPackage ./dnsmasq-china-list.nix { target = "unbound"; };
  };
  go-shadowsocks2 = callPackage ./go-shadowsocks2.nix { };
  gost = callPackage ./gost.nix { };
  ibus-engines.rime = callPackage ./ibus-rime.nix { };
  kcptun = callPackage ./kcptun.nix { };
  steven-black-hosts = callPackage ./steven-black-hosts.nix { };
  udpspeeder = callPackage ./udpspeeder.nix { };
  v2ray-plugin = callPackage ./v2ray-plugin.nix { };
  vlmcsd = callPackage ./vlmcsd.nix { };
}
