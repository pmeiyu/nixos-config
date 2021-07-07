{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "hosts";
  version = "2021.07.07";

  srcs = [
    (fetchFromGitHub {
      owner = "StevenBlack";
      repo = "hosts";
      rev = "3.7.13";
      sha256 = "0z1jw6vhdkifk694gajmg1dcw7sl05x3xl096dvmlw79224s69lx";
      name = "stevenblack-hosts";
    })
    (fetchFromGitHub {
      owner = "VeleSila";
      repo = "yhosts";
      rev = "0c5420334de278f2b38abde5bf46d8eff9a892da";
      sha256 = "0rk0yzy2b5dj8bavgvv5n3pik9cs09qaz70z2h5nradsjrlcafkp";
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
