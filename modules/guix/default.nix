{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.guix;
in
{
  imports = [ ./mirror.nix ];

  options = {
    services.guix = {
      enable = mkEnableOption "Enable Guix";
      acl = mkOption {
        type = types.path;
        default = ./acl;
        description = "ACL";
      };
      signing-key = {
        pub = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Public key of signing key pair.";
        };
        sec = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Private key of signing key pair.";
        };
      };
      substitute-urls = mkOption {
        type = types.listOf types.str;
        default = [
          "https://mirror.sjtu.edu.cn/guix"
          "https://ci.guix.gnu.org"
          "https://bordeaux.guix.gnu.org"
        ];
        description = "List of substitute URLs.";
      };
      max-jobs = mkOption {
        type = types.int;
        default =
          if (builtins.typeOf config.nix.maxJobs) == "int" then
            config.nix.maxJobs
          else
            4;
        description = "Max number of jobs.";
      };
      publish = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Publish guix store";
        };
        domain = mkOption {
          type = types.str;
          default = "builder.lan";
          description = "Domain name.";
        };
        enable-acme = mkOption {
          type = types.bool;
          default = false;
          description = "Enable ACME.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.variables = {
      GUIX_LOCPATH = "/var/guix/profiles/per-user/root/guix-profile/lib/locale";
    };

    environment.extraInit = ''
      # Guix
      if [ -d /var/guix/profiles/per-user/root ]; then
          export PATH=/var/guix/profiles/per-user/root/guix-profile/sbin:$PATH
          export PATH=/var/guix/profiles/per-user/root/guix-profile/bin:$PATH
          export PATH=/var/guix/profiles/per-user/root/current-guix/bin:$PATH
      fi
    '';

    networking.extraHosts = ''
      ::1       ${cfg.publish.domain}
      127.0.0.1 ${cfg.publish.domain}
    '';

    users.groups.guixbuild = { };
    users.users =
      let
        makeGuixBuildUser = n: {
          name = "guixbuilder${n}";
          value = {
            description = "Guix build user ${n}";
            group = "guixbuild";
            extraGroups = [ "guixbuild" ];
            isSystemUser = true;
          };
        };
        guixBuildUsers = lib.listToAttrs
          (map makeGuixBuildUser (map (lib.fixedWidthNumber 2) (lib.range 1 10)));
      in
      guixBuildUsers;

    environment.etc."guix/acl" = { source = cfg.acl; };
    environment.etc."guix/signing-key.pub" =
      mkIf (!isNull cfg.signing-key.pub) { source = cfg.signing-key.pub; };
    environment.etc."guix/signing-key.sec" =
      mkIf (!isNull cfg.signing-key.sec) {
        source = cfg.signing-key.sec;
        mode = "0400";
      };

    systemd.services.guix-daemon = {
      description = "Build daemon for GNU Guix";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart =
          "/var/guix/profiles/per-user/root/current-guix/bin/guix-daemon"
          + " --build-users-group=guixbuild"
          + " --substitute-urls='${toString cfg.substitute-urls}'"
          + " --max-jobs=${toString cfg.max-jobs}";
        Environment =
          "'GUIX_LOCPATH=/var/guix/profiles/per-user/root/guix-profile/lib/locale'"
          + " LC_ALL=en_US.utf8";
        TasksMax = 8192;
      };
    };

    systemd.services.guix-publish = mkIf cfg.publish.enable {
      description = "Publish the GNU Guix store";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "/var/guix/profiles/per-user/root/current-guix/bin/guix"
          + " publish --user=nobody --port=8181 --compression=lzip";
        Environment =
          "'GUIX_LOCPATH=/var/guix/profiles/per-user/root/guix-profile/lib/locale'"
          + " LC_ALL=en_US.utf8";
        TasksMax = 1024;
      };
    };

    services.nginx = mkIf cfg.publish.enable {
      enable = true;
      virtualHosts."${cfg.publish.domain}" = {
        addSSL = cfg.publish.enable-acme;
        enableACME = cfg.publish.enable-acme;

        locations."/guix/" = {
          extraConfig = ''
            proxy_pass http://localhost:8181/;
          '';
        };
        extraConfig = ''
          access_log /var/log/nginx/${cfg.publish.domain}.access.log;
          error_log  /var/log/nginx/${cfg.publish.domain}.error.log;
        '';
      };
    };
  };
}
