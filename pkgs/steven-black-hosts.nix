{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "steven-black-hosts";
  version = "2.6.22";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    sha256 = "0nhh37khgkmgpqv9126qji2q0f1ha0000sj948jj28al4ig48cxh";
  };

  buildPhase = ''
    mkdir -p build/unbound

    cp hosts build/ad

    for i in fakenews gambling porn social; do
        find extensions/$i -name hosts -exec cat '{}' >>build/$i \;
    done


    ## Unbound config

    echo 'view:' >build/unbound/ad.conf
    echo 'name: "block-ad"' >>build/unbound/ad.conf
    awk '/^0\.0\.0\.0|^127\.0\.0\.1/ {
        print "local-data: \"" $2 " 60 IN A 0.0.0.0\"";
        print "local-data: \"" $2 " 60 IN AAAA ::1\""
    }' hosts >>build/unbound/ad.conf

    for i in fakenews gambling porn social; do
        echo 'view:' >build/unbound/$i.conf
        echo "name: \"block-$i\"" >>build/unbound/$i.conf
        find extensions/$i -name hosts -exec \
            awk '/^0\.0\.0\.0|^127\.0\.0\.1/ {
                print "local-data: \"" $2 " 60 IN A 0.0.0.0\"";
                print "local-data: \"" $2 " 60 IN AAAA ::1\""
            }' '{}' >>build/unbound/$i.conf \;
    done
  '';

  installPhase = ''
    mkdir -p $out
    cp -rv build/* $out
  '';

  meta = with stdenv.lib; {
    description = "Steven Black's hosts files";
    homepage = "https://github.com/StevenBlack/hosts";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
