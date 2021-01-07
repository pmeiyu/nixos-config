{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "hosts";
  version = "2021.01.07";

  srcs = [
    (fetchFromGitHub {
      owner = "StevenBlack";
      repo = "hosts";
      rev = "3.3.2";
      sha256 = "06iafjn118ynrdsa3s530z6z7fd7whn73jh26wbdc8half6bpj45";
      name = "stevenblack-hosts";
    })
    (fetchFromGitHub {
      owner = "VeleSila";
      repo = "yhosts";
      rev = "a96a387675c1bc61d2ea4d730bdf2a8c9b74fd6c";
      sha256 = "0bq75m7qnxq7wskqirhf47f6dby4cqwxg4qji270sskzchbp44kq";
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

  meta = with stdenv.lib; {
    description = "DNS hosts file";
    platforms = platforms.all;
  };
}
