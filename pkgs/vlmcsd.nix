{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "vlmcsd";
  version = "1113";

  src = fetchFromGitHub {
    owner = "Wind4";
    repo = "vlmcsd";
    rev = "svn${version}";
    sha256 = "19qfw4l4b5vi03vmv9g5i7j32nifvz8sfada04mxqkrqdqxarb1q";
  };

  installPhase = ''
    install -v -D bin/* -t $out/bin
    install -v -D -m 644 etc/* -t $out/etc
    install -v -D -m 644 man/*.1 -t $out/share/man/man1
    install -v -D -m 644 man/*.5 -t $out/share/man/man5
    install -v -D -m 644 man/*.7 -t $out/share/man/man7
    install -v -D -m 644 man/*.8 -t $out/share/man/man8
  '';

  meta = with stdenv.lib; {
    description = "KMS Emulator in C";
    homepage = "https://github.com/Wind4/vlmcsd";
    platforms = platforms.all;
  };
}
