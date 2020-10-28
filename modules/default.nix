{ config, lib, pkgs, ... }:

{
  imports = [
    ./bluetooth.nix
    ./cloudflared.nix
    ./common
    ./deluge.nix
    ./desktop-gui.nix
    ./desktop.nix
    ./dns.nix
    ./emacs.nix
    ./gnome-flashback.nix
    ./gotify.nix
    ./guix
    ./hotspot.nix
    ./hydroxide.nix
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
    ./weechat.nix
    ./yubikey.nix
  ];
}
