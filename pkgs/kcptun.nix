{ lib, stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "kcptun";
  version = "20200701";

  src = fetchFromGitHub {
    owner = "xtaci";
    repo = "kcptun";
    rev = "v${version}";
    sha256 = "1icw6ih31h1hwkx7mz717d6y490fpmawvibaiw4vac8xisq32613";
  };

  vendorSha256 = "1gdikcpb6cgdacmb725nyvxijv2ccm4v0p8chsk57m5p62zb4cm5";

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
