{ lib, stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "kcptun";
  version = "20210624";

  src = fetchFromGitHub {
    owner = "xtaci";
    repo = "kcptun";
    rev = "v${version}";
    sha256 = "0x71hgipw826lkz9z9rp9qhkpym5006wv5grlpj64vvn3yp8wvrg";
  };

  vendorSha256 = null;

  postInstall = ''
    mv $out/bin/client $out/bin/kcptun-client
    mv $out/bin/server $out/bin/kcptun-server
  '';

  meta = with lib; {
    description = "Stable and secure tunnel with multiplexing and FEC";
    homepage = "https://github.com/xtaci/kcptun";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
