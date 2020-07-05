{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "go-shadowsocks2";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "shadowsocks";
    repo = "go-shadowsocks2";
    rev = "v${version}";
    sha256 = "0v7yirl2zkp67c9h22n61vckkawad354nsvyn9irvk5426c7zfid";
  };

  vendorSha256 = "0avlnbj8s6wnmgsavivyhk16wkh2ns0lp7xc1pi9rg2pkymcdmz7";

  meta = with stdenv.lib; {
    description = "Next-generation Shadowsocks in Go";
    homepage = "https://github.com/shadowsocks/go-shadowsocks2";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
