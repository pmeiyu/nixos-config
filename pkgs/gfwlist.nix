{ lib, stdenv, fetchFromGitHub, format ? "raw", upstream-dns ? "8.8.8.8" }:

stdenv.mkDerivation rec {
  pname = "gfwlist";
  version = "20201225";

  src = fetchFromGitHub {
    owner = "gfwlist";
    repo = "gfwlist";
    rev = "00819dfcae16e54b587005588ba568dba636f151";
    sha256 = "1zahki4yapldcmw8hbmlxm6px671nppgmfykjcpqxra54y71yjsk";
  };

  buildPhase = ''
    mkdir -p build

    base64 -d gfwlist.txt >gfwlist.raw.txt
    mv gfwlist.raw.txt gfwlist.txt

    awk '! /^\[|^!|^@|^\/|:|\/|%|*/ {
        if(match($0, /([0-9a-z-]+\.)+[a-z]+/)) {
            print substr($0, RSTART, RLENGTH)
        }
    }' gfwlist.txt | sort | uniq >gfwlist.domains.txt

    case ${format} in
    raw)
      cp gfwlist.txt gfwlist.domains.txt build/
      ;;
    dnsmasq)
      awk '{print "server=/" $0 "/${upstream-dns}"}' \
          gfwlist.domains.txt >build/gfwlist.dnsmasq.conf
      awk '{print "ipset=/" $0 "/gfwlist4,gfwlist6"}' \
          gfwlist.domains.txt >build/gfwlist.dnsmasq.ipset.conf
      ;;
    smartdns)
      awk '{print "nameserver /" $0 "/gfwlist"}' \
          gfwlist.domains.txt >build/gfwlist.smartdns.conf
      awk '{print "ipset /" $0 "/gfwlist4"}' \
          gfwlist.domains.txt >build/gfwlist.smartdns.ipset.conf
      ;;
    esac
  '';

  installPhase = ''
    mkdir -p $out
    cp -rv build/* $out
  '';

  meta = with lib; {
    description = "gfwlist";
    homepage = "https://github.com/gfwlist/gfwlist";
    license = licenses.lgpl21;
    platforms = platforms.all;
  };
}
