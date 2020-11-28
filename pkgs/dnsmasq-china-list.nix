{ lib, stdenv, fetchFromGitHub, upstream-server ? "114.114.114.114"}:

stdenv.mkDerivation rec {
  pname = "dnsmasq-china-list";
  version = "2020.06.19";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "cca913cc3575c0d200b52fcf34f5e0f12e1d811c";
    sha256 = "0a610x03f9hwr5jdsi91vxz6sz4xwad23idk0bn3b2n3dq3dhjfx";
  };

  prePatch = lib.optionalString (!isNull upstream-server) ''
    substituteInPlace Makefile \
        --replace 'SERVER=114.114.114.114' 'SERVER=${upstream-server}';
  '';

  buildPhase = ''
    make raw
    mkdir -p build/raw
    cp -v *.raw.txt build/raw

    make dnscrypt-proxy
    mkdir -p build/dnscrypt-proxy
    cp -v dnscrypt-proxy-forwarding-rules.txt build/dnscrypt-proxy

    make dnsmasq
    mkdir -p build/dnsmasq
    cp -v *.dnsmasq.conf build/dnsmasq
    cp -v bogus-nxdomain.china.conf build/dnsmasq

    make smartdns
    mkdir -p build/smartdns
    cp -v *.smartdns.conf build/smartdns
    sed -i 's|/${upstream-server}$|/china|' build/smartdns/*

    make unbound
    mkdir -p build/unbound
    cp -v *.unbound.conf build/unbound

    # ipset
    mkdir -p build/dnsmasq-ipset
    for i in accelerated-domains.china apple.china google.china; do
        awk '{print "ipset=/" $0 "/china4,china6"}' $i.raw.txt >build/dnsmasq-ipset/$i.conf
    done

    mkdir -p build/smartdns-ipset
    for i in accelerated-domains.china apple.china google.china; do
        awk '{print "ipset /" $0 "/china4"}' $i.raw.txt >build/smartdns-ipset/$i.conf
    done
  '';

  installPhase = ''
    mkdir -p $out
    cp -rv build/* $out
  '';

  meta = with stdenv.lib; {
    description = "dnsmasq china list";
    homepage = "https://github.com/felixonmars/dnsmasq-china-list";
    license = licenses.wtfpl;
    platforms = platforms.all;
  };
}
