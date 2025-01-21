{
  description = "Julia 1.5 environment, rebuilt with newer glibc/gcc";

  inputs = {
    # Current or recent Nixpkgs (we'll get stdenv.gcc11Stdenv from here):
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    # Old Nixpkgs commit that has the Julia 1.5 derivation:
    nixpkgs-julia-15.url = "github:NixOS/nixpkgs/75a93dfecc6c77ed7c35cc7f906175aca93facb4";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-julia-15, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      # 1) An overlay that imports the old Julia expression
      #    and overrides its stdenv to use the *current* system's gcc11Stdenv.
      overlayNixpkgsJulia15 = final: prev: {
        pkgs-julia-15 = import nixpkgs-julia-15 {
          inherit (final) system;
          overlays = [
            (final2: prev2: {
              julia_15 = prev2.julia_15.override {
                # Rebuild Julia 1.5 with new toolchain
                stdenv = final2.overrideCC final2.stdenv pkgs.gcc11;
                # If gcc11Stdenv fails, try final2.gcc10Stdenv or final2.gcc12Stdenv
              };
            })
          ];
        };
      };

      # 2) Bring in our main nixpkgs, apply the overlay that has the patched Julia.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;             # if you need unfree packages
        config.allowUnsupportedSystem = true;  # if needed
        overlays = [ overlayNixpkgsJulia15 ];
      };

      # 3) Our "newly rebuilt" Julia 1.5
      julia15Rebuilt = pkgs.pkgs-julia-15.julia_15;

    in {
      devShells.default = pkgs.mkShell {
        packages = [
          # The recompiled Julia 1.5.4
          julia15Rebuilt

          pkgs.cmake
          pkgs.gcc     # GCC 11.3.0
          pkgs.gdb
          pkgs.zlib
          pkgs.unzip
        ];

        shellHook = ''
          export JULIA_NUM_THREADS="auto"
          export JULIA_PROJECT="."
          export JULIA_BINDIR='${julia15Rebuilt}/bin'
          alias julia='${julia15Rebuilt}/bin/julia'
          export JULIA_EDITOR="code"

          echo "Julia 1.5 (rebuilt) is at: ${julia15Rebuilt}"
          echo "Julia 1.5 dev shell loaded."

          # needed for libraries:
          export LD_LIBRARY_PATH=/home/onyr/cplex1210/cplex/bin/x86-64_linux:$LD_LIBRARY_PATH
          export CPLEX_ROOT=/home/onyr/cplex1210
          export BAPCOD_ROOT=/home/onyr/bapcod/bapcod-0.82.8
          export BOOST_ROOT=/home/onyr/bapcod/bapcod-0.82.8/Tools/boost_1_76_0/build
          export BAPCOD_RCSP_LIB=/home/onyr/bapcod/bapcod-0.82.8/build/Bapcod/libbapcod-shared.so
        '';
      };
    }
  );
}
