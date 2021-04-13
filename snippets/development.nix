{ config, lib, pkgs, ... }:

{
  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  services.postgresql.enable = true;

  services.redis.enable = true;
}
