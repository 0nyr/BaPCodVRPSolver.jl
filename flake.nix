{
  description = "Julia 1.5 environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    nixpkgs-julia-15.url = "github:NixOS/nixpkgs/75a93dfecc6c77ed7c35cc7f906175aca93facb4"; # Pin to the specific commit

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-julia-15, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlay-nixpkgs-julia-15 = final: prev: {
          # Use the non-flake store path
          pkgs-julia-15 = import nixpkgs-julia-15 { inherit system; };
        };

        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true; # Allow unfree packages if needed
          overlays = [ overlay-nixpkgs-julia-15 ];
        };

        julia_15 = pkgs.pkgs-julia-15.julia_15.overrideDerivation (oldAttrs: { doInstallCheck = false; });
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            julia_15 # Use specific Julia 1.5.4

            pkgs.cmake
            pkgs.gcc
            pkgs.gdb
            pkgs.zlib
            pkgs.unzip

          ];

          shellHook = ''
            export JULIA_NUM_THREADS="auto"
            export JULIA_PROJECT="turing"
            export JULIA_BINDIR=${julia_15}/bin
            export JULIA_EDITOR="code"
            alias julia=${julia_15}/bin/julia
            export LD_LIBRARY_PATH=/home/onyr/cplex1210/cplex/bin/x86-64_linux:$LD_LIBRARY_PATH
            export CPLEX_ROOT=/home/onyr/cplex1210
            export BAPCOD_ROOT=/home/onyr/bapcod/bapcod-0.82.8
            export BOOST_ROOT=/home/onyr/bapcod/bapcod-0.82.8/Tools/boost_1_76_0/build
            echo "Julia 1.5 Nix shell loaded."
          '';
        };
      });
}
