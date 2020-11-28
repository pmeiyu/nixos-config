{ stdenv, fetchFromGitHub }:

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

    base64 -d gfwlist.txt >build/gfwlist.txt

    base64 -d gfwlist.txt | \
    awk '! /^\[|^!|^@|^\/|:|\/|%|*/ {
        if(match($0, /([0-9a-z-]+\.)+[a-z]+/)) {
            print substr($0, RSTART, RLENGTH)
        }
    }' | sort | uniq >>build/gfwlist.domains.txt

    awk '{print "ipset=/" $0 "/gfwlist4,gfwlist6"}' \
        build/gfwlist.domains.txt >build/gfwlist.dnsmasq.ipset.conf

    awk '{print "nameserver /" $0 "/gfwlist"}' \
        build/gfwlist.domains.txt >build/gfwlist.smartdns.conf
    awk '{print "ipset /" $0 "/gfwlist4"}' \
        build/gfwlist.domains.txt >build/gfwlist.smartdns.ipset.conf
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
