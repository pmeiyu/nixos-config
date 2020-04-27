{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "dnsmasq-china-list";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "9f0405431a5341648db00153be551c1be4fdbacc";
    sha256 = "1vq4vqzx0hlcn9dvi2zch19n0v9d0pjf2d5v9cibagrw5j1fnkda";
  };

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out
    cp -rv * $out
  '';

  meta = with stdenv.lib; {
    description = "dnsmasq china list";
    homepage = "https://github.com/felixonmars/dnsmasq-china-list";
    license = licenses.wtfpl;
    platforms = platforms.all;
  };
}
