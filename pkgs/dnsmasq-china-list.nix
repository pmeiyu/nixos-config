{ lib, stdenv, fetchFromGitHub, format ? "raw", upstream-dns ? "114.114.114.114"
, ipset ? false }:

stdenv.mkDerivation rec {
  pname = "dnsmasq-china-list";
  version = "2020.06.19";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "cca913cc3575c0d200b52fcf34f5e0f12e1d811c";
    sha256 = "0a610x03f9hwr5jdsi91vxz6sz4xwad23idk0bn3b2n3dq3dhjfx";
  };

  buildPhase = ''
    mkdir -p build
    make ${format} SERVER=${upstream-dns}
    cp -v *.${format}.{conf,txt} build/
  '' + lib.optionalString ipset ''
    case ${format} in
    dnsmasq)
      for i in accelerated-domains.china apple.china google.china; do
          awk '{print "ipset=/" $0 "/china4,china6"}' $i.raw.txt \
              >build/$i.${format}.ipset.conf
      done
      ;;
    smartdns)
      for i in accelerated-domains.china apple.china google.china; do
          awk '{print "ipset /" $0 "/china4"}' $i.raw.txt \
              >build/$i.${format}.ipset.conf
      done
      ;;
    esac
  '';

  installPhase = ''
    mkdir -p $out
    cp -rv build/* $out
  '';

  meta = with stdenv.lib; {
    description = "china list";
    homepage = "https://github.com/felixonmars/dnsmasq-china-list";
    license = licenses.wtfpl;
    platforms = platforms.all;
  };
}
