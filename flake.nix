{
  description = "Julia 1.5 environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/75a93dfecc6c77ed7c35cc7f906175aca93facb4"; # Pin to the specific commit
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true; # Allow unfree packages if needed
        };

        julia_15 = pkgs.julia_15.overrideDerivation (oldAttrs: { doInstallCheck = false; });
      in {
        devShells.default = pkgs.mkShell {
          packages = [
            julia_15 # Use Julia 1.5.4
          ];

          shellHook = ''
            export JULIA_NUM_THREADS="auto"
            export JULIA_PROJECT="turing"
            export JULIA_BINDIR=${julia_15}/bin
            export JULIA_EDITOR="code"
            echo "Julia 1.5 Nix shell loaded."
          '';
        };
      });
}
