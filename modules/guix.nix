{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.guix;
in
{
  options = {
    my.guix = {
      enable = mkEnableOption "Enable Guix";
      substitute-urls = mkOption {
        type = types.listOf types.str;
        default = [
          "https://mirror.sjtu.edu.cn/guix/"
          "https://ci.guix.gnu.org/"
          "https://bordeaux.guix.gnu.org/"
        ];
        description = "List of substitute URLs.";
      };
      max-jobs = mkOption {
        type = types.int;
        default =
          if (builtins.typeOf config.nix.settings.max-jobs) == "int" then
            config.nix.settings.max-jobs
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
    services.guix = {
      enable = true;
      extraArgs = [
        "--substitute-urls='${toString cfg.substitute-urls}'"
        "--max-jobs=${toString cfg.max-jobs}"
      ];

      publish = mkIf cfg.publish.enable {
        enable = true;
        extraArgs = [
          "--compression=zstd:9"
        ];
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
