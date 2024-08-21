{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "cargo_lock_builder";
  version = "1.0.0";
  src = ./.;
  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];
  buildInputs = with pkgs; [
    bash
    curl
    gnutar
    cargo
    cacert
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp cargo_lock_builder.sh $out/bin/cargo-lock-builder
    chmod +x $out/bin/cargo-lock-builder

    wrapProgram $out/bin/cargo-lock-builder \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.curl pkgs.gnutar pkgs.cargo pkgs.cacert ]} \
      --set SSL_CERT_FILE ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
  '';

  meta = with pkgs.lib; {
    description = "Generates Cargo.lock files so you can run more updated versions of tools built from crates.io";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
