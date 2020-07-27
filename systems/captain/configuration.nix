{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./private.nix

    ../..
  ];

  my.deluge.enable = true;
  my.desktop.enable = true;
  my.desktop.gui.enable = true;
  my.monitor.enable = true;
  my.network.prefer-ipv4 = true;
  my.nginx.enable = true;
  my.samba.enable = true;

  ## Nix

  nix.binaryCaches = lib.mkForce [ "https://cache.nixos.org/" ];

  ## Boot loader

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ## Hardware

  hardware.cpu.intel.updateMicrocode = true;
  hardware.usbWwan.enable = true;

  ## Environment

  networking.hostName = "captain";

  ## Network

  networking.search = [ ];

  networking.networkmanager = {
    ethernet.macAddress = "random";
    wifi.macAddress = "random";
  };

  ## Programs

  programs.adb.enable = true;
  programs.java.enable = true;

  environment.systemPackages = with pkgs; [
    qemu

    # GUI
    virtmanager
  ];

  ## Services

  services.xserver.desktopManager.gnome3.enable = true;

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" "/srv/store" ];
  };

  services.guix = {
    enable = true;
    substitute-urls = "https://mirror.guix.org.cn";
  };

  services.syncthing = {
    enable = true;
    user = "meiyu";
    group = config.users.users.meiyu.group;
    dataDir = config.users.users.meiyu.home;
    openDefaultPorts = true;
  };

  services.tor = {
    enable = true;
    client.enable = true;
    client.transparentProxy.enable = true;
    extraConfig = ''
      Socks5Proxy localhost:1080
    '';
  };

  virtualisation.libvirtd.enable = true;
}
