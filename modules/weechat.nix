{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.weechat;
in
{
  options = {
    my.weechat = {
      enable = mkEnableOption "Enable WeeChat.";
      relay.port = mkOption {
        type = types.int;
        default = 8697;
        description = "WeeChat relay port.";
      };
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.packageOverrides = pkgs: rec {
      weechat = pkgs.weechat.override {
        configure = { availablePlugins, ... }: {
          scripts = with pkgs.weechatScripts; [
            weechat-matrix
          ];
        };
      };
    };

    environment.systemPackages = [
      (pkgs.writeScriptBin "chat" ''
        #!${pkgs.runtimeShell}
        tmux -L weechat attach -t weechat
      '')
    ];

    systemd.services.weechat = {
      serviceConfig = {
        Type = "oneshot";
        User = "meiyu";
        RemainAfterExit = "yes";
        ExecStart =
          "${pkgs.tmux}/bin/tmux -T 256 -L weechat new-session -d -s weechat ${pkgs.weechat}/bin/weechat";
        ExecStop = "${pkgs.tmux}/bin/tmux -L weechat kill-session -t weechat";
        Environment = "TMUX_TMPDIR=/run/user/1000";
      };
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };

    services.nginx = {
      virtualHosts.localhost.locations."/weechat/" = {
        proxyPass = "http://localhost:${toString cfg.relay.port}";
        proxyWebsockets = true;
        extraConfig = ''
          access_log off;
        '';
      };
    };
  };
}
