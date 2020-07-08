{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.common;
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSWDNLrevEMD83aVXEAoCirJxWxI1Ft5AlK15KipL+x"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCj1ZPwtIShm3hMX7/uw151jVZeg927viEakb12/FTQ+gj+wmbEvnsjFvavLZ+u0e2yqijK0b/i/ptcJ/o1duNs228N4Nqib55HXPSsmq6nwOYyMk7DQc2KcjzCRPgqUsiQeFFKkDoWZGS5C7sJCO5QDfYIpfMSwKOSJM2TipdkWJlioP4xTS9ma+KtkNMc/B2ceMXRRyepF4DgaySOALE0dx1xcglwMKrqf9f7e1ceyc9sFNJRLEa5p9tvGWRmTNcb/WWybc1RHrxuUA7onB0MhqHYJgYpUy3q/kHk3vIeKLdATBILIPlj3uwwW62R0H6a3eKxqIwmL34hD+O/3D+WrtPWpTw4aRqoSyIH+tWnvKGz08yFlxcxkmxxwA1oXsTkRXXO6Wi3VJoWdcD6FIfknBj+m/v7veGECeavLSX5p3SLFQkftU62l82mNE7M/4yr2uXqRsSeHoQLarBaij+2eQilcOsVzxDD53xdSibPvz+jmSss+6WYqowyBuAimIQq9z6N2yzkfc772SwLDpab5AvLKNfmKQJXpZD+uT/cA5LiCcmo72CAJkp8e6OQqqtGpbVsFxRTf5uPlk8xC12RxBQzHpG0F8/ltLIBDvypktMBJ69hxI6yq9HjjMAK467VxHP1DeYtcr1KZNnVo0oQWBILuhMTtfpMf/m5LmS7yw=="
  ];
in {
  options = {
    my.common = { enable = mkEnableOption "Enable common configurations."; };
  };

  config = mkIf cfg.enable {
    ## Nix

    nix.binaryCachePublicKeys = [ ];

    ## Boot

    boot.cleanTmpDir = true;

    ## Kernel

    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = "100000";
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.ip_forward" = "1";
      "net.ipv6.conf.all.forwarding" = "1";
    };

    ## Environment

    time.timeZone = "Asia/Shanghai";

    environment.variables = lib.mkDefault {
      EDITOR = "zile";
      VISUAL = "zile";
    };

    ## User accounts

    users.mutableUsers = false;
    users.users = {
      root = {
        # Generate hashed password: `mkpasswd -m sha-512`
        hashedPassword = null;
        passwordFile = "/etc/password";

        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = authorizedKeys;
      };
      meiyu = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [
          "audio"
          "docker"
          "input"
          "kvm"
          "libvirtd"
          "lp"
          "netdev"
          "networkmanager"
          "video"
          "wheel"
        ];
        password = config.users.users.root.password;
        hashedPassword = config.users.users.root.hashedPassword;
        passwordFile = config.users.users.root.passwordFile;
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = authorizedKeys;
      };
      guest = { isSystemUser = true; };
    };
    security.pam.enableSSHAgentAuth = true;
    security.sudo.wheelNeedsPassword = false;

    environment.interactiveShellInit = ''
      # Automatically start tmux on interactive SSH shell.
      if [ -t 0 ] && [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ] && \
          command -v tmux >/dev/null;
      then
          # If no tmux session is started, start a new session.
          if tmux has-session; then
              exec tmux attach
          else
              exec tmux new-session
          fi
      fi
    '';

    environment.etc."tmux.conf" = { source = ./tmux.conf; };

    ## Certificates

    security.pki.certificateFiles = [ ./PMY-CA.pem ];
    security.pki.caCertificateBlacklist = [ "CFCA EV ROOT" ];

    ## Services

    services.journald.extraConfig = ''
      SystemMaxUse=1G
    '';

    services.fail2ban.enable = true;

    services.openssh = {
      enable = true;
      passwordAuthentication = false;
    };

    ## Programs

    nixpkgs.config.packageOverrides = pkgs: rec {
      my-python = pkgs.python3.withPackages
        (python-packages: with python-packages; [ pytz requests ]);
    };

    programs.fish.enable = true;
    programs.iftop.enable = true;
    programs.iotop.enable = true;
    programs.mosh.enable = true;
    programs.mtr.enable = true;
    programs.tmux.enable = true;
    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
      curl
      dnsutils
      fd
      file
      fzf
      git
      gnupg
      gotop
      htop
      iptables
      lsof
      lzip
      nmap
      openssl
      psmisc
      pv
      rsync
      socat
      tcpdump
      tree
      wget
      xxd
      zile
      zstd

      my-python

      termite # Install terminfo file for termite.
    ];
  };
}
