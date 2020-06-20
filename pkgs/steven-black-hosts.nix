{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "steven-black-hosts";
  version = "2.6.22";

  src = fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = version;
    sha256 = "0nhh37khgkmgpqv9126qji2q0f1ha0000sj948jj28al4ig48cxh";
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
