{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.emacs;
in
{
  options = {
    my.emacs.enable = mkEnableOption "Enable emacs.";
  };

  config = mkIf cfg.enable {
    environment.variables = {
      EDITOR = "emacs";
      VISUAL = "emacs";
    };

    environment.systemPackages = with pkgs; [
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      emacs
    ];
  };
}
