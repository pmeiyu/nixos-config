{ lib, stdenv, fetchFromGitHub, stevenblack-blocklist }:

stdenv.mkDerivation rec {
  pname = "hosts";
  version = "2023.11.18";

  srcs = [
    (fetchFromGitHub {
      owner = "VeleSila";
      repo = "yhosts";
      rev = "765d0136241fb26f027f7843441992f80985486b";
      hash = "sha256-nNeVNCqZy3KTL22mXpfmuEevWOxWbgqqza2A5IG67ho=";
      name = "yhosts";
    })
  ];

  sourceRoot = ".";

  buildPhase = ''
    mkdir -p build

    for i in ${stevenblack-blocklist}/hosts yhosts/hosts.txt; do
        awk -e '/^#/ { print; next; }' \
            -e '/^@/ { print "#" $0; next; }' \
            -e '/^ *$/ { printf "\n"; next; }' \
            -e '$1 ~ /0\.0\.0\.0|127\.0\.0\.1/ && $2 !~ /0\.0\.0\.0$|.*local[^.]*$/ {
                print tolower($2)
            }' $i | \
        uniq >>build/ad
    done

    for i in fakenews gambling porn social; do
        find ${stevenblack-blocklist}/extensions/$i -name hosts -exec \
        awk -e '/^#/ { print; next; }' \
            -e '/^ *$/ { printf "\n"; next; }' \
            -e '$1 ~ /0\.0\.0\.0|127\.0\.0\.1/ && $2 !~ /0\.0\.0\.0$|.*local[^.]*$/ {
                print tolower($2)
            }' '{}' \; | \
        uniq >>build/$i
    done

    ## RouteDNS

    mkdir -p build/routedns

    for i in ad fakenews gambling porn social; do
        awk '!/^#|^ *$/' build/$i | \
        # Split and reverse domain names.
        awk -F"." '{for(i=NF; i>1; i--) printf "%s ", $i; print $i}' | \
        sort | uniq | \
        # Restore domain names.
        awk '{for(i=NF; i>1; i--) printf "%s.", $i; print $i}' | \
        awk '{print "." $0}' >>build/routedns/$i
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
    description = "Domain names";
  };
}
