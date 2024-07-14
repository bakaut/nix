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
          src = if builtins.pathExists /nix/store/${sha256} then /nix/store/${sha256} else pkgs.fetchurl {
            inherit url sha256;
          };

          buildInputs = [ pkgs.libarchive pkgs.unzip ];

          phases = [ "unpackPhase" "installPhase" ];

          unpackPhase = ''
            runHook preUnpack
            rm -f /nix/bin/${name}
            mkdir -p $TMPDIR/tmp
            if [[ "$src" == *.tar.gz ]]; then
              tar tzf $src
              tar xzf $src -C $TMPDIR/tmp
            elif [[ "$src" == *.zip ]]; then
              unzip -l $src
              unzip $src -d $TMPDIR/tmp
            elif [[ "$src" == *sops* ]]; then
              cp $src $TMPDIR/tmp/
            else
              echo "Unsupported archive format"
              exit 1
            fi
            runHook postUnpack
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp $(find . -type f -name "*${name}*") $out/bin/${name}
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
        terraform = mkPackage {
          name = "terraform";
          url = "https://releases.hashicorp.com/terraform/1.8.5/terraform_1.8.5_darwin_amd64.zip";
          sha256 = "BRxwLhVqTRocYoeDzyyg4duMyntMDxaG6mI1WO1VYPk=";
        };
        sops = mkPackage {
          name = "sops";
          url = "https://github.com/mozilla/sops/releases/download/v3.7.1/sops-v3.7.1.darwin";
          sha256 = "Q9L5xjkhpXv2ByaKBdSAzDCemXm7gSaSSN0Rfl76wTM=";
        };
        helm = mkPackage {
          name = "helm";
          url = "https://get.helm.sh/helm-v3.15.3-darwin-arm64.tar.gz";
          sha256 = "ntU7Gc/ZNZCMUmm6PogChGL8TCSfhfk3rozAS2/pzq0=";
        };
      };
    };

    defaultPackages = {
      "aarch64-darwin" = [
        self.packages."aarch64-darwin".flux
        self.packages."aarch64-darwin".terraform
        self.packages."aarch64-darwin".sops
      ];
    };
  };
}
