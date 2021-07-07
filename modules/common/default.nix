{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.common;
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSWDNLrevEMD83aVXEAoCirJxWxI1Ft5AlK15KipL+x"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGixg7L7vRFgmxBS2GmI4/UqPw7pERi3qbKFUPaEZIF"
  ];
in
{
  options = {
    my.common = { enable = mkEnableOption "Enable common configurations."; };
  };

  config = mkIf cfg.enable {
    ## Nix

    nix.binaryCachePublicKeys = [ ];

    # Enable flakes.
    nix.package = pkgs.nixFlakes;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    ## Boot

    boot.cleanTmpDir = true;

    ## Kernel

    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = "100000";
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    ## Environment

    networking.domain = mkDefault "xqzp.net";

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
          "adbusers"
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
          "wireshark"
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

    environment.etc."pki/PMY-CA.pem".source = ./PMY-CA.pem;


    ## Network

    networking.firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ ];
    };

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
      home-manager
      ncdu
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
    ];
  };
}
