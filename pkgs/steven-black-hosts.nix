{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "steven-black-hosts";
  version = "2.5.65";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    sha256 = "1c0r0f4vbgd772ymjimny1gcypjcmhjk1bim5mhscb0gmg4rxn7v";
  };

  installPhase = ''
    mkdir -p $out
    cp -rv * $out
  '';

  meta = with stdenv.lib; {
    description = "Steven Black's hosts files";
    homepage = "https://github.com/StevenBlack/hosts";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
