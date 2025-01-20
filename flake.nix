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

        # julia_15 = pkgs.pkgs-julia-15.julia_15.overrideAttrs (old: {
        #   postFixup = old.postFixup or "" + ''
        #     echo "Removing old libstdc++ from Julia..."
        #     rm $out/lib/julia/libstdc++.so.6
        #     ln -s ${pkgs.stdenv.cc.cc}/lib/libstdc++.so.6 $out/lib/julia/libstdc++.so.6
        #   '';
        # });
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            julia_15 # Use specific Julia 1.5.4

            pkgs.cmake
            pkgs.gcc # v11.3.0
            pkgs.gdb
            pkgs.zlib
            pkgs.unzip

          ];

          shellHook = ''
            export JULIA_NUM_THREADS="auto"
            export JULIA_PROJECT="."
            export JULIA_BINDIR=${julia_15}/bin
            export JULIA_EDITOR="code"
            echo "Julia 1.5 here: ${julia_15}"
            alias julia=${julia_15}/bin/julia
            export LD_LIBRARY_PATH=/home/onyr/cplex1210/cplex/bin/x86-64_linux:$LD_LIBRARY_PATH
            export CPLEX_ROOT=/home/onyr/cplex1210
            export BAPCOD_ROOT=/home/onyr/bapcod/bapcod-0.82.8
            export BOOST_ROOT=/home/onyr/bapcod/bapcod-0.82.8/Tools/boost_1_76_0/build
            export BAPCOD_RCSP_LIB=/home/onyr/bapcod/bapcod-0.82.8/build/Bapcod/libbapcod-shared.so
            echo "Julia 1.5 Nix shell loaded."
            echo "${pkgs.stdenv.cc.cc}"
            ls ${pkgs.gcc.cc.lib}/lib/libstdc++.so.6
            export LD_PRELOAD="${pkgs.gcc.cc.lib}/lib/libstdc++.so.6"
            export LD_LIBRARY_PATH="${pkgs.gcc.cc.lib}/lib:$LD_LIBRARY_PATH"
          '';
        };
      });
}
