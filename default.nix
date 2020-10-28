{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules
  ];

  nixpkgs.config.packageOverrides = pkgs: import ./pkgs { pkgs = pkgs; };
}
