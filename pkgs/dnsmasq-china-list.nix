{ lib
, stdenv
, fetchFromGitHub
, format ? "raw"
, upstream-dns ? "114.114.114.114"
, enable-ipset ? false
, enable-nftset ? false
}:

stdenv.mkDerivation rec {
  pname = "dnsmasq-china-list";
  version = "2021.04.07";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "0cdcf4abdd077d1dc379650fe9c04f0f19fa3958";
    sha256 = "5TivzgYqkEguXvqtnh/OdjFCOdq3vWgLn2YORyybdDU=";
  };

  buildPhase = ''
    mkdir -p build
    make ${format} SERVER=${upstream-dns}
    cp -v *.${format}.{conf,txt} build/
  '' + (lib.optionalString enable-ipset ''
    case ${format} in
    dnsmasq)
      for i in accelerated-domains.china apple.china google.china; do
          awk '{print "ipset=/" $0 "/china4,china6"}' $i.raw.txt \
              >build/$i.${format}.ipset.conf
      done
      ;;
    smartdns)
      for i in accelerated-domains.china apple.china google.china; do
          awk '{print "ipset /" $0 "/#4:china4,#6:china6"}' $i.raw.txt \
              >build/$i.${format}.ipset.conf
      done
      ;;
    esac
  '') + (lib.optionalString enable-nftset ''
    case ${format} in
    dnsmasq)
      for i in accelerated-domains.china apple.china google.china; do
          awk '{print "nftset=/" $0 "/4#inet#filter#china4";
                print "nftset=/" $0 "/6#inet#filter#china6"}' $i.raw.txt \
              >build/$i.${format}.nftset.conf
      done
      ;;
    esac
  '');

  installPhase = ''
    mkdir -p $out
    cp -rv build/* $out
  '';

  meta = with lib; {
    description = "china list";
    homepage = "https://github.com/felixonmars/dnsmasq-china-list";
    license = licenses.wtfpl;
  };
}
