{ stdenv, fetchFromGitHub, cmake, pkgconfig, gdk-pixbuf, glib, ibus, libnotify
, librime, brise }:

stdenv.mkDerivation rec {
  pname = "ibus-rime";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "rime";
    repo = "ibus-rime";
    rev = version;
    sha256 = "0zbajz7i18vrqwdyclzywvsjg6qzaih64jhi3pkxp7mbw8jc5vhy";
  };

  buildInputs = [ gdk-pixbuf glib ibus libnotify librime brise ];
  nativeBuildInputs = [ cmake pkgconfig ];

  makeFlags = [ "PREFIX=$(out)" ];
  dontUseCmakeConfigure = true;

  prePatch = ''
    substituteInPlace Makefile \
       --replace 'cmake' 'cmake -DRIME_DATA_DIR=${brise}/share/rime-data'

    substituteInPlace rime_config.h \
       --replace '/usr' $out

    substituteInPlace rime_config.h \
       --replace 'IBUS_RIME_SHARED_DATA_DIR IBUS_RIME_INSTALL_PREFIX' \
                 'IBUS_RIME_SHARED_DATA_DIR "${brise}"'

    substituteInPlace rime.xml \
       --replace '/usr' $out
  '';

  meta = with stdenv.lib; {
    isIbusEngine = true;
    description = "Rime Input Method Engine for IBus";
    homepage = "https://rime.im/";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
