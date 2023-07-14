{
  description = "htop";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: (
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      pythonEnv = pkgs.python3.withPackages (python-packages: [
        python-packages.fastapi
	python-packages.ipython
	python-packages.uvloop
      ]);
      env = pkgs.buildEnv {
        name = "test";
	paths = [
	  pkgs.coreutils
	  pkgs.bash
	  pythonEnv
	];
      };
    in
      {
        # packages = {
	#   htop = htop;
	# };
	defaultPackage = env;
      }
    )
  );
}
