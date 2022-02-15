{ config, lib, pkgs, ... }:

{
  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };

  services.mysql = {
    enable = true;
    package = pkgs.mysql80;
    settings = { };
  };

  services.postgresql.enable = true;

  services.redis.servers."".enable = true;
}
