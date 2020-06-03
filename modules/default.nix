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
    ./monitor.nix
    ./network.nix
    ./nginx.nix
    ./pi-fan-control
    ./samba.nix
    ./server.nix
    ./snapper.nix
    ./vlmcsd.nix
    ./weechat.nix
    ./yubikey.nix
  ];
}
