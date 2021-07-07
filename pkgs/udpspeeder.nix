{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "udpspeeder";
  version = "20210116.0";

  src = fetchFromGitHub {
    owner = "wangyu-";
    repo = "UDPspeeder";
    rev = version;
    sha256 = "0ki8h2is2j0in55dq7z14rd8f7wi95s5izqyjbiyqdv250ji9jzh";
  };

  patchPhase = ''
    substituteInPlace makefile \
       --replace '$(shell git rev-parse HEAD)' '${version}' \
       --replace "-static" ""
  '';

  installPhase = ''
    install -v -D speederv2 $out/bin/udpspeeder
  '';

  meta = with lib; {
    description = "UDP tunnel with forward error correction";
    homepage = "https://github.com/wangyu-/UDPspeeder/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
