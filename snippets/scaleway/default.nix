{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ./overlay.nix) ];

  networking.nameservers = [
    # # Public NAT64 Services - nat64.xyz
    # "2a00:1098:2b::1"
    # "2a0b:f4c0:4d:53::1"

    # # CloudFlare Public DNS
    # "2606:4700:4700::1111"

    # # Google Public DNS
    # "2001:4860:4860::8888"
  ];

  environment.systemPackages = with pkgs; [
    scaleway
  ];

  systemd.services.scw-net-ipv6 = {
    description = "Configure IPv6 networking";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      source <(scw-metadata)
      set -o xtrace
      ip -6 addr add dev eth0 $IPV6_ADDRESS/$IPV6_NETMASK
      ip -6 route replace default via $IPV6_GATEWAY
    '';
    path = with pkgs; [ iproute scaleway ];
  };
}
