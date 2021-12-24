{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.desktop;
in
{
  options = {
    my.desktop.enable = mkEnableOption "Enable desktop configurations.";
  };

  config = mkIf cfg.enable {
    my.common.enable = true;
    my.dns = {
      enable = mkDefault true;
      block.ad = mkDefault true;
      chinalist.enable = mkDefault true;
      gfwlist.enable = mkDefault true;
      log.enable = mkDefault true;
    };
    my.emacs.enable = true;


    ## Nix

    system.stateVersion = mkDefault "9999.99";

    nix.binaryCaches = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.bfsu.edu.cn/nix-channels/store/"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store/"
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
    boot.loader.grub.configurationLimit = mkDefault 20;
    boot.loader.systemd-boot.configurationLimit = mkDefault 20;


    ## Kernel

    boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;
    boot.kernelParams = [ "boot.shell_on_fail" ];


    ## Hardware

    powerManagement.cpuFreqGovernor = mkDefault "powersave";

    services.logind.lidSwitchExternalPower = "lock";

    hardware.gpgSmartcards.enable = true;

    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    security.tpm2 = {
      enable = true;
      abrmd.enable = true;
      pkcs11.enable = true;
    };


    ## Environment

    # Center of China
    location = {
      provider = "manual";
      latitude = 34.0;
      longitude = 115.0;
    };


    ## Network

    system.nssDatabases.hosts = [ "mdns" ];

    networking.networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };

    networking.usePredictableInterfaceNames = mkDefault false;


    ## Programs

    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;

    programs.zsh.ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    environment.systemPackages = with pkgs; [
      _7zz
      alsaUtils
      binutils
      btrfs-progs
      compsize
      cryptsetup
      dosfstools
      efibootmgr
      espeak
      ffmpeg
      file
      fortune
      fuse
      gnumake
      imagemagick7
      iw
      libnotify
      lolcat
      mkpasswd
      mpc_cli
      mpd
      ncdu
      neo-cowsay
      neofetch
      nixpkgs-fmt
      ntfsprogs
      parted
      progress
      pulseaudio
      ripgrep
      sl
      sqlar
      sqlite
      sshfs-fuse
      stow
      strace
      telnet
      tpm2-tools
      unzip
      xdg-user-dirs
      xdg_utils

      # Hardware
      dmidecode
      lm_sensors
      nvme-cli
      pciutils
      powertop
      smartmontools
      usbutils
    ];


    ## Services

    services.btrfs.autoScrub.enable = true;
    services.fstrim.enable = true;

    # Smart card
    services.pcscd.enable = true;
  };
}
