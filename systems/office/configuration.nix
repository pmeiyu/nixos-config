{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ./hardware-configuration.nix
    ./private.nix
    ./development.nix
  ];

  my.bluetooth.enable = true;
  my.deluge.enable = true;
  my.desktop.enable = true;
  my.desktop.gui.enable = true;
  my.gnome-flashback.enable = true;
  my.monitor.enable = true;
  my.network.prefer-ipv4 = true;
  my.nginx.enable = true;
  my.samba.enable = true;
  my.snapper = {
    enable = true;
    enable-home = true;
  };
  my.virtualization.enable = true;
  my.weechat.enable = true;

  ## Nix

  system.autoUpgrade.enable = true;

  nix.maxJobs = 8;

  ## Boot loader

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ## Hardware

  hardware.cpu.intel.updateMicrocode = true;
  hardware.pulseaudio.systemWide = true;

  ## Environment

  networking.hostName = "office";

  ## Network

  networking.search = [ ];

  networking.networkmanager = {
    # ethernet.macAddress = "random";
    wifi.macAddress = "random";
  };

  # networking.proxy.default = "http://localhost:1081";
  # networking.proxy.noProxy = "127.0.0.1,localhost";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 445 1081 ];
    allowedTCPPortRanges = [{
      from = 8000;
      to = 8999;
    }];
    extraCommands = ''
      ip6tables -I INPUT -p esp -j ACCEPT
    '';
    extraStopCommands = ''
      ip6tables -D INPUT -p esp -j ACCEPT
    '';
  };

  networking.interfaces.eth0.mtu = 1492;

  ## Programs

  programs.adb.enable = true;
  programs.bandwhich.enable = true;
  programs.thefuck.enable = true;
  programs.wireshark.enable = true;
  programs.zmap.enable = true;

  environment.systemPackages = with pkgs; [
    goaccess
    httpie
    ngrep
    qemu
    tldr

    # GUI
    arc-icon-theme
    arc-theme
    gnome3.gnome-tweaks
    sqlitebrowser
    virtmanager
  ];

  ## Services

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.xserver.windowManager.stumpwm.enable = true;
  services.xrdp = {
    enable = true;
    defaultWindowManager = "i3";
  };

  services.printing.enable = true;

  services.guix = {
    enable = true;
    publish.enable = true;
    mirror.enable = true;
    mirror.upstream = "mirror.guix.org.cn";
    signing-key.pub = ../../local/guix/signing-key.pub;
    signing-key.sec = ../../local/guix/signing-key.sec;
  };

  services.ipfs = {
    enable = true;
    autoMount = true;
    enableGC = false;
    dataDir = "/srv/store/ipfs";
    extraConfig = { Datastore.StorageMax = "100GB"; };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings = {
      mysqld = {
        innodb_strict_mode = 0;
      };
    };
  };
  services.postgresql.enable = true;
  services.redis.enable = true;

  services.syncthing = {
    enable = true;
    user = "meiyu";
    group = config.users.users.meiyu.group;
    dataDir = config.users.users.meiyu.home;
    openDefaultPorts = true;
  };

  systemd.services.mpd = {
    description = "mpd";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon --stdout";
      User = "meiyu";
    };
  };
}
