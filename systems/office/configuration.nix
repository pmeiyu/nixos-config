{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./private.nix

    ../..
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
    enable-store = true;
  };
  my.weechat.enable = true;
  my.yubikey.enable = true;

  ## Nix

  system.autoUpgrade.enable = true;

  # HTTP is faster than HTTPS in my office.
  nix.binaryCaches = lib.mkForce [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "http://cache.nixos.org/"
  ];

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

  networking.interfaces.enp1s0 = { mtu = 1492; };

  ## Programs

  programs.adb.enable = true;
  programs.java.enable = true;
  programs.thefuck.enable = true;

  environment.systemPackages = with pkgs; [
    bandwhich
    goaccess
    httpie
    nethogs
    ngrep
    qemu

    # GUI
    arc-icon-theme
    arc-theme
    gnome3.gnome-tweaks
    sqlitebrowser
    virtmanager
  ];

  ## Services

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" "/srv/store" ];
  };

  services.xserver.windowManager.stumpwm.enable = true;

  services.printing.enable = true;
  services.zookeeper.enable = true;

  # Virtualization
  virtualisation.libvirtd.enable = true;
  security.wrappers.spice-client-glib-usb-acl-helper.source =
    "${pkgs.spice_gtk}/bin/spice-client-glib-usb-acl-helper";

  virtualisation.docker = {
    enable = true;
    extraOptions = "--registry-mirror=https://registry.docker-cn.com";
  };

  # services.kubernetes = {
  #   roles = [ "master" "node" ];
  #   masterAddress = "localhost";
  #   kubelet.extraOpts = "--fail-swap-on=false";
  # };

  services.dnsmasq.extraConfig = ''
    conf-dir=/etc/dnsmasq.d/,*.conf
  '';

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
