{
  description = "A template flake to install software from a URL with a specified SHA256";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv/latest";
  };

  outputs = { self, nixpkgs, unstable, devenv }: {
    packages = {
      "aarch64-darwin" = let
        pkgs = import nixpkgs { system = "aarch64-darwin"; };
        unstablePkgs = import unstable { system = "aarch64-darwin"; };

        # Helper function to create a package from a URL and SHA256
        mkPackage = { name, url, sha256 }: pkgs.stdenv.mkDerivation {
          inherit name;
          src = pkgs.fetchurl {
            inherit url sha256;
          };

          buildInputs = [ pkgs.libarchive ];

          phases = [ "unpackPhase" "installPhase" ];

          unpackPhase = ''
            runHook preUnpack
            mkdir -p $TMPDIR/tmp
            tar tzf $src
            tar xzf $src -C $TMPDIR/tmp
            runHook postUnpack
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp $TMPDIR/tmp/${name} $out/bin/
            cp $out/bin/${name} /nix/bin/
            chmod +x /nix/bin/${name}
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "A custom package for ${name}.";
            homepage = "https://example.com";
            license = licenses.asl20;
            platforms = platforms.all;
          };
        };

      in {
        flux = mkPackage {
          name = "flux";
          url = "https://github.com/fluxcd/flux2/releases/download/v2.2.3/flux_2.2.3_darwin_arm64.tar.gz";
          sha256 = "JSn7XruBDOZmYmI1bik5goKnp2bfTn6VypOkD7gC9FI=";
        };
      };
    };
  };
}
