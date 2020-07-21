{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.desktop;
in {
  options = {
    my.desktop = { enable = mkEnableOption "Enable desktop configurations."; };
  };

  config = mkIf cfg.enable {
    my.common.enable = true;
    my.dns = {
      enable = true;
      block.ad = true;
      dnsmasq-china-list.enable = true;
    };
    my.emacs.enable = true;

    ## Nix

    system.stateVersion = lib.mkDefault "20.09";

    system.autoUpgrade = {
      enable = lib.mkDefault false;
      channel = lib.mkDefault "https://nixos.org/channels/nixos-unstable";
    };

    nix.gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 30d";
    };

    nix.trustedUsers = [ "root" "@wheel" ];

    ## Boot

    # Limit number of entries in boot menu.
    boot.loader.grub.configurationLimit = mkDefault 5;

    ## Kernel

    boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;
    boot.kernelParams = [ "boot.shell_on_fail" ];

    ## Hardware

    sound.enable = true;
    hardware.pulseaudio.enable = true;

    ## Environment

    # Center of China
    location = {
      provider = "manual";
      latitude = 34.0;
      longitude = 115.0;
    };

    ## Network

    networking.networkmanager.enable = true;
    system.nssDatabases.hosts = [ "mdns" ];

    # Programs
    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;
    programs.zsh.ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    environment.systemPackages = with pkgs; [
      alsaUtils
      aria2
      badvpn
      binutils
      btrfs-progs
      cowsay
      cryptsetup
      dosfstools
      efibootmgr
      espeak
      ffmpeg
      fortune
      fuse
      gnumake
      gotify-cli
      imagemagick7
      iptables
      jq
      libnotify
      lolcat
      mkpasswd
      mpc_cli
      mpd
      msmtp
      mu
      ncmpcpp
      neofetch
      nethogs
      nftables
      ntfsprogs
      offlineimap
      parallel
      parted
      pciutils
      progress
      pulseaudio
      rclone
      ripgrep
      sl
      sqlite
      sshfs-fuse
      stow
      strace
      telnet
      unzip
      usbutils
      xdg-user-dirs
      xdg_utils
      youtube-dl

      # Hardware
      lm_sensors
      powertop
      smartmontools
    ];

    ## Services

    services.fstrim.enable = true;
  };
}
