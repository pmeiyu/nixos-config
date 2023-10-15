self: super: with super; {
  scaleway-image-tools = stdenv.mkDerivation {
    pname = "scaleway";
    version = "2019.04.30";

    src = fetchFromGitHub {
      owner = "scaleway";
      repo = "image-tools";
      rev = "8d224da40fca3df75215109a98e17cbc4e16c7ae";
      hash = "sha256-Cu1zmoHIhjlz+59pg2DteM9pxFW/yP4Rs6pNAiUXB50=";
    };

    buildInputs = [ curl makeWrapper ];

    buildPhase = "true";

    installPhase = ''
      mkdir -p $out/bin
      cp -rv bases/overlay-common/usr/local/bin/scw-metadata $out/bin
      cp -rv bases/overlay-common/usr/local/bin/scw-metadata-json $out/bin

      runHook postInstall
    '';

    postInstall = ''
      wrapProgram $out/bin/scw-metadata \
          --prefix PATH : ${lib.makeBinPath [ curl ]}
      wrapProgram $out/bin/scw-metadata-json \
          --prefix PATH : ${lib.makeBinPath [ curl ]}
    '';
  };
}
