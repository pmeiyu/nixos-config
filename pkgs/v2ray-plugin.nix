{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "v2ray-plugin";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "shadowsocks";
    repo = "v2ray-plugin";
    rev = "v${version}";
    sha256 = "01z2q9ra0cn43wncsza7nhi1lq3q2yzgknmar8wy90g7rrmg72jl";
  };

  patches = [ ./v2ray-plugin.patch ];

  modSha256 = "1s5vshbbpqdxc9fm19df7j61afvdyq6ihgdqwqmd0v9mjg3sigkc";

  meta = with stdenv.lib; {
    description = "Shadowsocks SIP003 plugin based on v2ray";
    homepage = "https://github.com/shadowsocks/v2ray-plugin";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
