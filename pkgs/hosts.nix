{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "hosts";
  version = "2020.11.18";

  srcs = [
    (fetchFromGitHub {
      owner = "StevenBlack";
      repo = "hosts";
      rev = "3.2.3";
      sha256 = "03h90p569kb0k594vqv36bccfcscjyrbqqd9gyr2jvhjlbyh3rlb";
      name = "stevenblack-hosts";
    })
    (fetchFromGitHub {
      owner = "VeleSila";
      repo = "yhosts";
      rev = "021aead99b2c3bb5a7e1450a5217fcfd1f9fe287";
      sha256 = "1bijz65fy29fgfmdp16nb8kdvc14rbj8lf0h31v2yi5wjfxgv6vi";
      name = "yhosts";
    })
  ];

  sourceRoot = ".";

  buildPhase = ''
    mkdir -p build/unbound

    # StevenBlack hosts

    cp stevenblack-hosts/hosts build/ad

    for i in fakenews gambling porn social; do
        find stevenblack-hosts/extensions/$i -name hosts \
             -exec cat '{}' >>build/$i \;
    done

    # yhosts

    cat yhosts/hosts >>build/ad

    ## Unbound config

    for i in ad fakenews gambling porn social; do
        echo 'view:' >build/unbound/block-$i.conf
        echo "name: \"block-$i\"" >>build/unbound/block-$i.conf
        awk '/^0\.0\.0\.0|^127\.0\.0\.1/ {
            print "local-data: \"" $2 " 60 IN A 0.0.0.0\"";
            print "local-data: \"" $2 " 60 IN AAAA ::1\""
        }' build/$i >>build/unbound/block-$i.conf
    done
  '';

  installPhase = ''
    mkdir -p $out
    cp -rv build/* $out
  '';

  meta = with stdenv.lib; {
    description = "hosts files";
    platforms = platforms.all;
  };
}
