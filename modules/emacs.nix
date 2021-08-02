{ config, lib, pkgs, ... }:

with lib;
let cfg = config.my.emacs;
in
{
  options = {
    my.emacs = {
      enable = mkEnableOption "Enable emacs.";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.packageOverrides = pkgs: rec {
      my-emacs-config = pkgs.writeText "default.el" ''
        (require 'package)
        (package-initialize 'noactivate)
        (eval-when-compile (require 'use-package))

        (use-package nix-mode)
      '';
      my-emacs = pkgs.emacsWithPackages (epkgs:
        (with epkgs.melpaStablePackages; [
          (pkgs.runCommand "default.el" { } ''
            mkdir -p $out/share/emacs/site-lisp
            cp ${my-emacs-config} $out/share/emacs/site-lisp/default.el
          '')
          nix-mode
          use-package
        ]));
    };

    environment.variables = {
      EDITOR = "emacs";
      VISUAL = "emacs";
    };

    environment.systemPackages = with pkgs; [
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      my-emacs
    ];
  };
}
