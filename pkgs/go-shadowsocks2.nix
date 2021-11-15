{ lib, stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "go-shadowsocks2";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "shadowsocks";
    repo = "go-shadowsocks2";
    rev = "v${version}";
    sha256 = "0n24h5ffgc3735y0mmp6dbhxdfm9fk13i26fqxxw7i75qnmvjvyg";
  };

  vendorSha256 = "035r73c2vs53g6akdnz2nki73p44sq81sffldnf4irhkc6qy9ca6";

  meta = with lib; {
    description = "Next-generation Shadowsocks in Go";
    homepage = "https://github.com/shadowsocks/go-shadowsocks2";
    license = licenses.asl20;
  };
}
