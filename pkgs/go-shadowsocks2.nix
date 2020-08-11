{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "go-shadowsocks2";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "shadowsocks";
    repo = "go-shadowsocks2";
    rev = "v${version}";
    sha256 = "1gi29xbszi8flg9sv0b75gy2sb37q4zva39p262da2qaprzm0990";
  };

  vendorSha256 = "0iyak8af708h3rdrslndladbcjrix35j3rlhpsb8ljchqp09lksg";

  meta = with stdenv.lib; {
    description = "Next-generation Shadowsocks in Go";
    homepage = "https://github.com/shadowsocks/go-shadowsocks2";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}
