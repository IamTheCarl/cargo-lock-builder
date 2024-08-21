# Cargo Lock Builder

Nix is designed to produce declarative and reproducable development and build environments. It is like this with Rust as well.
When installing an application from a Rust package, Nix will build that application using exactly the dependencies referenced in that application's Cargo.lock.

Some tools, like [dioxus-cli](https://github.com/DioxusLabs/dioxus/issues/2867#issuecomment-2299843521) expect to have their dependencies updated every time you install them. This can result in annoying situations where the version of dependencies in dioxus-cli must match with your application, but you can't change the version used by dioxus-cli because it's fixed by the Cargo.lock on [crates.io](https://crates.io).

## A manual solution
This problem can be resolved manually by downloading the package's source from `https://crates.io/api/v1/crates/{crate of interest}/{version number}/download`, extracting that file as a tar.gz, running `cargo update` in the project directory that produces, and then using the Cargo.lock file produced by that process in the Nix build.

## An automated solution (what this Repository provides)

This repository provides `cargo-lock-builder`, a command which will automatically produce the lock file you desire.
In the case of the previous example, run `cargo-lock-builder dioxus-cli 0.5.6` and you'll end up with a file named `dioxus-cli.lock` that you can use to build a fresh version of the create.

Also since you'll probably need it, here's an example of how to build the crate with the generated lock file.

```nix
dioxus-cli = rust_platform.buildRustPackage rec {
  pname = "dioxus-cli";
  version = "0.5.6";
  src = pkgs.fetchCrate {
    inherit pname version;
    sha256 = "sha256-cOd8OGkmebUYw6fNLO/kja81qKwqBuVpJqCix1Izf64";
  };
  cargoLock = {
    lockFileContents = (builtins.readFile ./dioxus-cli.lock);
  };
  postPatch = ''
    rm Cargo.lock
    ln -s ${./dioxus-cli.lock} Cargo.lock
  '';

  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ pkgs.openssl ];

  checkFlags = [
    # requires network access, thanks nixpkgs for figuring this out
    "--skip=server::web::proxy::test::add_proxy"
    "--skip=server::web::proxy::test::add_proxy_trailing_slash"
  ];

  # Tell openssl-sys to use the system's provided openssl.
  OPENSSL_NO_VENDOR = 1;
};
```
