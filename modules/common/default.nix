{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.my.common;
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGixg7L7vRFgmxBS2GmI4/UqPw7pERi3qbKFUPaEZIF"
  ];
in
{
  options = {
    my.common.enable = mkEnableOption "Enable common configurations.";
  };

  config = mkIf cfg.enable {
    ## Nix

    nix.settings = {
      substituters = [
        "https://cache.nixos.org"
      ];
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://pmy.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "pmy.cachix.org-1:E9ExJaENh8OOqBxWdel0EcSGY4MOGikB+36IuPvs6Hw="
      ];
      trusted-users = [ "root" "@wheel" ];
      allowed-users = [ "root" "@wheel" "@users" ];
    };

    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';


    ## Boot

    boot.tmp.cleanOnBoot = true;


    ## Kernel

    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = "100000";
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };


    ## Environment

    time.timeZone = "Asia/Shanghai";

    environment.variables = lib.mkDefault {
      EDITOR = "zile";
      VISUAL = "zile";
    };


    ## User accounts

    system.activationScripts.my-user-accounts = ''
      ${pkgs.systemd}/bin/loginctl enable-linger meiyu
    '';

    users.mutableUsers = false;
    users.users = {
      root = {
        # Generate hashed password: `mkpasswd -m sha-512`
        hashedPassword = null;
        hashedPasswordFile = "/etc/secrets/password";

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
        hashedPasswordFile = config.users.users.root.hashedPasswordFile;
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = authorizedKeys;
      };
      guest = {
        isSystemUser = true;
        group = "users";
      };
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


    ## Certificates

    security.pki.certificateFiles = [ ./ca.pem ];
    security.pki.caCertificateBlacklist = [ ];

    environment.etc."pki/ca.pem".source = ./ca.pem;


    ## Network

    networking.firewall = {
      enable = true;
      extraPackages = with pkgs; [ iproute2 ];
      allowPing = true;
      pingLimit = "2/second burst 2 packets";
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
      filterForward = true;
    };

    networking.nftables = {
      enable = true;
      tables = {
        filter = {
          family = "inet";
          content = ''
            chain output {
              type filter hook output priority filter - 1; policy accept;

              # Accept loopback traffic
              oif lo accept

              # Count HTTP traffic
              tcp sport 80 counter accept
              tcp sport 443 counter accept
              tcp dport 80 counter accept
              tcp dport 443 counter accept

              # Count output traffic
              counter accept comment "accepted output traffic"
            }
          '';
        };
      };
    };


    ## Services

    services.journald.extraConfig = ''
      SystemMaxUse=1G
    '';

    services.fail2ban.enable = true;

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };


    ## Programs

    nixpkgs.config.packageOverrides = pkgs: rec {
      my-python = pkgs.python3.withPackages
        (python-packages: with python-packages; [ requests ]);
    };

    programs.fish.enable = true;
    programs.iftop.enable = true;
    programs.iotop.enable = true;
    programs.mosh.enable = true;
    programs.mtr.enable = true;
    programs.zsh.enable = true;

    programs.tmux.enable = true;
    programs.tmux.extraConfig = readFile ./tmux.conf;

    environment.systemPackages = with pkgs; [
      btrfs-progs
      curl
      dnsutils
      dosfstools
      efibootmgr
      fd
      fzf
      git
      home-manager
      htop
      jq
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
    ];
  };
}
