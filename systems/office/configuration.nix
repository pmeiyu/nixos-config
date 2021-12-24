{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../snippets/cpu/intel.nix
    ../../snippets/gpu/intel.nix
    ../../snippets/development.nix
    ./hardware-configuration.nix
    ./private.nix
  ];

  my.deluge.enable = true;
  my.desktop.enable = true;
  my.desktop.gui.enable = true;
  my.monitor.enable = true;
  my.mpd.enable = true;
  my.network.prefer-ipv4 = true;
  my.nginx.enable = true;
  my.samba.enable = true;
  my.snapper = {
    enable = true;
    enable-home = true;
  };
  my.syncthing.enable = true;
  my.virtualization.enable = true;
  my.webdav.enable = true;
  my.weechat.enable = true;


  ## Nix

  nix.autoOptimiseStore = true;

  system.autoUpgrade.enable = true;


  ## Boot loader

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  ## Hardware

  powerManagement.cpuFreqGovernor = "performance";

  hardware.bluetooth.enable = true;


  ## Kernel

  boot.kernelModules = [
    "nct6775"
  ];

  boot.kernelParams = [
    "intel_iommu=on"

    # Fix GPU PCI passthrough bug.
    "video=efifb:off"
  ];


  ## Environment

  networking.hostName = "office";


  ## Network

  networking.search = [ ];

  networking.networkmanager = {
    ethernet.macAddress = "random";
    wifi.macAddress = "random";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 445 ];
    allowedTCPPortRanges = [{
      from = 8000;
      to = 8999;
    }];
  };

  # Fix network issue.
  networking.interfaces.eth0.mtu = 1492;


  ## Programs

  programs.bandwhich.enable = true;
  programs.thefuck.enable = true;
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  programs.zmap.enable = true;

  environment.systemPackages = with pkgs; [
    goaccess
    tldr

    # GUI
    gnome.gnome-tweaks
  ];


  ## Services

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.windowManager.dwm.enable = true;
  services.xserver.windowManager.stumpwm.enable = true;

  services.blueman.enable = true;
  services.dictd.enable = true;
  services.guix.enable = true;
  services.printing.enable = true;

  services.clamav = {
    daemon.enable = false;
    updater.enable = true;
  };

  # services.kubernetes = {
  #   roles = [ "master" "node" ];
  #   masterAddress = "localhost";
  #   kubelet.extraOpts = "--fail-swap-on=false";
  # };

  virtualisation.docker = {
    enable = true;
    extraOptions = "--registry-mirror=https://registry.docker-cn.com";
  };
}
