{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../snippets/thinkpad.nix
    ./hardware-configuration.nix
    ./private.nix
  ];

  my.desktop.enable = true;
  my.desktop.gui.enable = true;

  my.dns.hosts = [
    "10.1.0.1 pi.home"
  ];
  my.guix.enable = true;
  my.hydroxide.enable = true;
  my.mpd.enable = true;
  my.network.prefer-ipv4 = true;
  my.nginx.enable = true;
  my.overlay-networks.enable = true;
  my.snapper = {
    enable = true;
    enable-home = true;
  };
  my.syncthing.enable = true;


  ## Boot loader

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  ## Environment

  networking.hostName = "captain";


  ## Network

  networking.search = [ ];

  networking.networkmanager = {
    ethernet.macAddress = "random";
    wifi.macAddress = "random";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
  };


  ## Programs

  programs.wireshark.enable = true;

  environment.systemPackages = with pkgs; [ ];


  ## Services

  services.xserver.desktopManager.gnome.enable = true;

  services.blueman.enable = true;
}
