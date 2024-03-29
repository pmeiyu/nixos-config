{ lib
, stdenv
, fetchFromGitHub
, format ? "raw"
, upstream-dns ? "114.114.114.114"
, enable-nftset ? false
}:

stdenv.mkDerivation rec {
  pname = "dnsmasq-china-list";
  version = "2022.01.04";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "44996ac6d8206970e06a99a0a86b2f7f689893cd";
    hash = "sha256-nUUyCWCxxEExqQ7SJc4tjphWDLYEmkGbuROeK+T03rM=";
  };

  buildPhase = ''
    mkdir -p build

    case ${format} in
    routedns)
      make raw SERVER=${upstream-dns}
      for i in accelerated-domains.china; do
          awk '{print "." $0}' $i.raw.txt >build/$i.${format}.txt
      done
      for i in apple.china google.china; do
          cp -v $i.raw.txt build/$i.${format}.txt
      done
      ;;
    *)
      make ${format} SERVER=${upstream-dns}
      cp -v *.${format}.{conf,txt} build/
      ;;
    esac
  '' + (lib.optionalString enable-nftset ''
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
