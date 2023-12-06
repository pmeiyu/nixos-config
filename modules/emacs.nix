{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.emacs;
in
{
  options = {
    my.emacs = {
      enable = mkEnableOption "Enable emacs.";
      package = mkOption {
        type = types.package;
        default = pkgs.emacs;
        defaultText = literalExpression "pkgs.emacs";
        description = lib.mdDoc ''
          Emacs package to use.
        '';
      };
    };
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

      cfg.package
    ];
  };
}
