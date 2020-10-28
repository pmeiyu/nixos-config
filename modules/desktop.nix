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
      enable = mkDefault true;
      block.ad = mkDefault true;
      dnsmasq-china-list.enable = mkDefault true;
      ipset.enable = mkDefault true;
    };
    my.emacs.enable = true;

    ## Nix

    system.stateVersion = mkDefault "20.09";

    nix.binaryCaches = lib.mkForce [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store/"
      "https://cache.nixos.org/"
    ];

    system.autoUpgrade = {
      enable = mkDefault false;
      channel = mkDefault "https://nixos.org/channels/nixos-unstable";
    };

    nix.gc = {
      automatic = mkDefault true;
      dates = mkDefault "weekly";
      options = mkDefault "--delete-older-than 30d";
    };

    nix.trustedUsers = [ "root" "@wheel" ];

    ## Boot

    # Limit number of entries in boot menu.
    boot.loader.grub.configurationLimit = mkDefault 5;
    boot.loader.systemd-boot.configurationLimit = mkDefault 5;

    ## Kernel

    boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;
    boot.kernelParams = [ "boot.shell_on_fail" ];

    ## Hardware

    powerManagement.cpuFreqGovernor = mkDefault "powersave";

    services.logind.lidSwitchExternalPower = "lock";

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

    networking.usePredictableInterfaceNames = false;

    ## Programs
    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;
    programs.zsh.ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    environment.systemPackages = with pkgs; [
      alsaUtils
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
      iw
      jq
      libnotify
      lolcat
      mkpasswd
      mpc_cli
      mpd
      neofetch
      nethogs
      nftables
      ngrep
      nixfmt
      ntfsprogs
      parallel
      parted
      pciutils
      progress
      pulseaudio
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

      # Hardware
      lm_sensors
      powertop
      smartmontools
    ];

    ## Services

    services.btrfs.autoScrub.enable = true;
    services.fstrim.enable = true;

    # Smart card
    services.pcscd.enable = true;
  };
}
