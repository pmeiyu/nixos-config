{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "dnsmasq-china-list";
  version = "2020.06.19";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = "dnsmasq-china-list";
    rev = "cca913cc3575c0d200b52fcf34f5e0f12e1d811c";
    sha256 = "0a610x03f9hwr5jdsi91vxz6sz4xwad23idk0bn3b2n3dq3dhjfx";
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
