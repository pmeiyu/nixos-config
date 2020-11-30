{ stdenv, fetchFromGitHub, format ? "raw", upstream-dns ? "8.8.8.8" }:

stdenv.mkDerivation rec {
  pname = "gfwlist";
  version = "20200718";

  src = fetchFromGitHub {
    owner = "gfwlist";
    repo = "gfwlist";
    rev = "2f378a86f2fba8849a241fdb3f00c768960a102e";
    sha256 = "1kab4jxhgq70zidb8cnqgkcpvkfmmwrc4jxfskq1bfpdsxcxdjnj";
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

  meta = with stdenv.lib; {
    description = "gfwlist";
    homepage = "https://github.com/gfwlist/gfwlist";
    license = licenses.lgpl21;
    platforms = platforms.all;
  };
}
