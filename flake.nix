{
  description = "Julia environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Override the Nix package set to allow unfree packages
        pkgs = import nixpkgs {
          system = system; 
          config.allowUnfree = true; 
        };

        # WARN: Nix packaging system doesn't support all packages, so rely on Julia package manager instead.
        # Use Julia in REPL mode, then package mode and install packages that way.
        # WARN: Using a specific version of Julia to avoid compatibility issues.
        julia_15 = pkgs.stdenv.mkDerivation {
          name = "julia-1.5.4";
          src = pkgs.fetchurl {
            url = "https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-1.5.4-linux-x86_64.tar.gz";
            sha256 = "sha256-gN7DUdGlk+itFSY2lxpI0Mgb/Pq5LIfzYEZjYW8ei8U=";
          };
          installPhase = ''
            mkdir -p $out
            cp -r * $out
          '';
        };
      in
      {
        # development environment
        devShells.default = pkgs.mkShell {
          packages = [
            julia_15
          ];

          shellHook = ''
            export JULIA_NUM_THREADS="auto"
            export JULIA_PROJECT="turing"
            export JULIA_BINDIR=${julia_15}/bin
            export JULIA_EDITOR="code"
            echo "Nix shell loaded."
          '';
        };
      }
    );
}