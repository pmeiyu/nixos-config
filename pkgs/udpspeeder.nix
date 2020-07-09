{ stdenv, fetchFromGitHub}:

stdenv.mkDerivation rec {
  pname = "udpspeeder";
  version = "20190121.0";

  src = fetchFromGitHub {
    owner = "wangyu-";
    repo = "UDPspeeder";
    rev = version;
    sha256 = "1fjcbypxgmmamq796alqx52n6is70q55bdfzskv9c1320rbcv9ir";
  };

  patchPhase = ''
    substituteInPlace makefile \
       --replace '$(shell git rev-parse HEAD)' '${version}' \
       --replace "-static" ""
  '';

  installPhase = ''
    install -v -D speederv2 $out/bin/udpspeeder
  '';

  meta = with stdenv.lib; {
    description = "UDP tunnel with forward error correction";
    homepage = "https://github.com/wangyu-/UDPspeeder/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
