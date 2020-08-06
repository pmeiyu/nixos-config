{ config, lib, pkgs, ... }:

{
  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };

  virtualisation.docker = {
    enable = true;
    extraOptions = "--registry-mirror=https://registry.docker-cn.com";
  };

  # services.kubernetes = {
  #   roles = [ "master" "node" ];
  #   masterAddress = "localhost";
  #   kubelet.extraOpts = "--fail-swap-on=false";
  # };

  services.zookeeper.enable = true;
}
