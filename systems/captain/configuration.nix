{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../snippets/development.nix
    ../../snippets/thinkpad-x270.nix
    ./hardware-configuration.nix
    ./private.nix
  ];

  my.desktop.enable = true;
  my.desktop.gui.enable = true;
  my.hydroxide.enable = true;
  my.mpd.enable = true;
  my.network.prefer-ipv4 = true;
  my.nginx.enable = true;
  my.overlay-networks.enable = true;
  my.syncthing.enable = true;
  my.virtualization.enable = true;

  ## Nix

  nix.maxJobs = 4;

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

  services.xserver.desktopManager.gnome3.enable = true;

  services.blueman.enable = true;
  services.guix.enable = true;
}
