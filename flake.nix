{
  description = "Python container with compiled entrypoint";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = ({ self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          # localSystem = system;
          # crossSystem = "x86_64-linux";
          inherit system;
        };
        mkEntrypointSrc = (args:
          let
            quoteArg= arg: "\"${arg}\"";
            wrappedArgs = builtins.concatStringsSep ", " (map quoteArg args);
          in ''
            #include <unistd.h>
            void main(int argc, char *argv[]) {
              char *args[] = {${wrappedArgs}, NULL};
              execvp(args[0], args);
            }
          ''
        );
        mkEntrypoint = ({name, args}:
          pkgs.stdenv.mkDerivation {
            name = name;
            src = pkgs.writeText "${name}.c" (mkEntrypointSrc args);
            dontUnpack = true;
            buildPhase = ''
              $CC -o $name $src
            '';
            installPhase = ''
              mkdir -p $out/bin
              cp $name $out/bin
            '';
          }
        );
        entrypoint = mkEntrypoint {
          name = "entrypoint";
          args = [
            "${pkgs.python3}/bin/python3" "-m" "http.server" "-d" "/"
          ];
	};
      in {
        defaultPackage = entrypoint;
      }
    )
  );
}

        # packages = flake-utils.lib.flattenTree {
        #   service_env = pkgs.buildEnv {
        #   name = "env";
        #   paths = [ pkgs.s6 pkgs.coreutils pkgs.bash ];
        # };
        # devShells.default = pkgs.mkShell {
        #   buildInputs = [
        #   ];
        # };

