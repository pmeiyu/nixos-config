let pkgs = import <nixpkgs> { };
in {
  dnsmasq-china-list = pkgs.callPackage ./dnsmasq-china-list.nix { };
  go-shadowsocks2 = pkgs.callPackage ./go-shadowsocks2.nix { };
  ibus-engines.rime = pkgs.callPackage ./ibus-rime.nix { };
  kcptun = pkgs.callPackage ./kcptun.nix { };
  steven-black-hosts = pkgs.callPackage ./steven-black-hosts.nix { };
  v2ray-plugin = pkgs.callPackage ./v2ray-plugin.nix { };
  vlmcsd = pkgs.callPackage ./vlmcsd.nix { };
}
