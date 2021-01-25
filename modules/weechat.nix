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
    systemd.services.weechat = {
      serviceConfig = {
        Type = "oneshot";
        User = "meiyu";
        RemainAfterExit = "yes";
        ExecStart =
          "${pkgs.tmux}/bin/tmux -2 new-session -d -s irc ${pkgs.weechat}/bin/weechat";
        ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t irc";
      };
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };

    services.nginx = {
      virtualHosts.localhost.locations."/weechat/" = {
        extraConfig = ''
          access_log off;
          proxy_pass http://localhost:${toString cfg.relay.port};

          # Proxy WebSocket
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
          proxy_read_timeout 86400;
        '';
      };
    };

    environment.systemPackages = [
      (pkgs.writeScriptBin "irc" ''
        #!${pkgs.runtimeShell}
        export TERM=xterm-256color
        tmux -S /tmp/tmux-${
          toString config.users.users.meiyu.uid
        }/default attach -t irc
      '')
    ];
  };
}
