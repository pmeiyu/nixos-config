{ config, lib, pkgs, ... }:

{
  imports = [
    ./common
    ./deluge.nix
    ./desktop-gui.nix
    ./desktop.nix
    ./dns.nix
    ./emacs.nix
    ./gnome-flashback.nix
    ./gotify.nix
    ./guix.nix
    ./hotspot.nix
    ./hydroxide.nix
    ./jellyfin.nix
    ./monitor.nix
    ./mpd.nix
    ./network.nix
    ./nginx.nix
    ./overlay-networks.nix
    ./raspberry-pi
    ./samba.nix
    ./server.nix
    ./snapper.nix
    ./syncthing.nix
    ./tun2socks.nix
    ./virtualization.nix
    ./vlmcsd.nix
    ./webdav.nix
    ./weechat.nix
  ];
}
