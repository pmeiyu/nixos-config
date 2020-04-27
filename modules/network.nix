{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.network;
in {
  options = {
    my.network.prefer-ipv4 = mkEnableOption "Prefer IPv4 over IPv6";
  };

  config = {
    environment.etc."gai.conf" = mkIf cfg.prefer-ipv4 {
      text = ''
        label ::1/128       0
        label ::/0          1
        label 2002::/16     2
        label ::/96         3
        label ::ffff:0:0/96 4
        precedence ::1/128       50
        precedence ::/0          40
        precedence 2002::/16     30
        precedence ::/96         20
        precedence ::ffff:0:0/96 45
      '';
    };
  };
}
