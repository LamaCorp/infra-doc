{
  # name = "lama-corp-doc";
  description = "Lama Corp. Infrastructure user and admin docs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    futils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, futils }:
    let
      inherit (nixpkgs) lib;
      inherit (futils.lib) eachDefaultSystem defaultSystems;
      inherit (lib) recursiveUpdate;

      nixpkgsFor = lib.genAttrs defaultSystems (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      });

      ddorn = {
        email = "diego.dorn@free.fr";
        name = "Diego Dorn";
        github = "ddorn";
        githubId = 27305483;
      };
    in
    recursiveUpdate

    {
      overlay = final: prev: {
        lama-corp-doc = final.stdenv.mkDerivation {
          pname = "lama-corp-doc";
          version = "1.0.0";

          src = self;

          buildInputs = [
            (final.poetry2nix.mkPoetryEnv {
              projectDir = self;
            })
          ];

          buildPhase = ''
            mkdocs build
          '';

          installPhase = ''
            mkdir -p $out/share/
            mv site/ $out/share/html
          '';

          meta = with lib; {
            inherit (self) description;
            maintainers = with maintainers; [ risson ddorn ];
            license = licenses.mit;
          };
        };
      };
    }

    (eachDefaultSystem (system:
      let
        pkgs = nixpkgsFor.${system};
      in
      {
        devShell = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.lama-corp-doc ];
          buildInputs = [ pkgs.poetry ];
        };

        packages = {
          inherit (pkgs) lama-corp-doc;
        };

        defaultPackage = self.packages.${system}.lama-corp-doc;
      }));
}
