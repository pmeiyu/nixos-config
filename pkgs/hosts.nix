{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "hosts";
  version = "2021.04.07";

  srcs = [
    (fetchFromGitHub {
      owner = "StevenBlack";
      repo = "hosts";
      rev = "3.6.1";
      sha256 = "+O/1AUZ74BoOZOShf/WkGi/f9XNz+RHXUium5p6dEjM=";
      name = "stevenblack-hosts";
    })
    (fetchFromGitHub {
      owner = "VeleSila";
      repo = "yhosts";
      rev = "d15d71338e9802859acefa588c44590035c2399d";
      sha256 = "3NDrv9qk2C55z8yeKIydDBXyJdP+Mt+LRYxFfhiWF+k=";
      name = "yhosts";
    })
  ];

  sourceRoot = ".";

  buildPhase = ''
    mkdir -p build

    for i in stevenblack-hosts/hosts yhosts/hosts.txt; do
        awk -e '/^#/ { print; next; }' \
            -e '/^@/ { print "#" $0; next; }' \
            -e '/^ *$/ { printf "\n"; next; }' \
            -e '$1 ~ /0\.0\.0\.0|127\.0\.0\.1/ && $2 !~ /0\.0\.0\.0$|.*local[^.]*$/ {
                print tolower($2)
            }' $i | \
        uniq >>build/ad
    done

    for i in fakenews gambling porn social; do
        find stevenblack-hosts/extensions/$i -name hosts -exec \
        awk -e '/^#/ { print; next; }' \
            -e '/^ *$/ { printf "\n"; next; }' \
            -e '$1 ~ /0\.0\.0\.0|127\.0\.0\.1/ && $2 !~ /0\.0\.0\.0$|.*local[^.]*$/ {
                print tolower($2)
            }' '{}' \; | \
        uniq >>build/$i
    done

    ## Unbound config

    mkdir -p build/unbound

    for i in ad fakenews gambling porn social; do
        echo 'view:' >build/unbound/block-$i.conf
        echo "name: \"block-$i\"" >>build/unbound/block-$i.conf
        echo "view-first: yes" >>build/unbound/block-$i.conf

        awk '!/^#|^ *$/' build/$i | \
        # Split and reverse domain names.
        awk -F"." '{for(i=NF; i>1; i--) printf "%s ", $i; print $i}' | \
        sort | uniq | \
        # Restore domain names.
        awk '{for(i=NF; i>1; i--) printf "%s.", $i; print $i}' | \
        awk '{
            print "local-zone: " $0 ". refuse";
        }' >>build/unbound/block-$i.conf
    done
  '';

  installPhase = ''
    mkdir -p $out
    cp -rv build/* $out
  '';

  meta = with lib; {
    description = "DNS hosts file";
    platforms = platforms.all;
  };
}
