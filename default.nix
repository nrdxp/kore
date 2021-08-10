{ profiling ? false
, system ? builtins.currentSystem
, release ? false
, threaded ? !profiling
, checkMaterialization ? false

# Override `src` when this project is imported as a Git submodule:
#
# > ttuegel.cleanGitSubtree {
# >   name = "kore";
# >   src = ./parent/repo;
# >   subDir = "path/to/submodule";
# > };
#
# Use `cleanGitSubtree` whenever possible to preserve the same source code
# layout as the kframework/kore repository (to enable cache re-use).
#
, src ? null
}:

let
  sources = import ./nix/sources.nix { inherit system; };
  haskell-nix = import sources."haskell.nix" { inherit system; };
  inherit (haskell-nix) pkgs;
  inherit (pkgs) lib;

  ttuegel =
    let
      src = builtins.fetchGit {
        url = "https://github.com/kreisys/nix-lib";
        rev = "e62c580ac0d2e8133bb2f3326c312ac86d348277";
        ref = "main";
      };
    in import src { inherit pkgs; };
in

let
  project = pkgs.haskell-nix.stackProject {
    src = ttuegel.cleanSourceWith {
      name = "kore";
      src = ttuegel.orElse src (ttuegel.cleanGitSubtree { src = ./.; });
      ignore = [
        "/*"
        "!/stack.yaml"
        "!/kore"
      ];
    };
    inherit checkMaterialization;
    materialized = ./nix/kore.nix.d;
    modules = [
      {
        # package *
        enableLibraryProfiling = true;
        profilingDetail = "none";
        # package kore
        packages.kore = {
          flags = {
            inherit release threaded;
          };
          enableLibraryProfiling = profiling;
          enableExecutableProfiling = profiling;
          profilingDetail = "toplevel-functions";

          # Add Z3 to PATH for unit tests.
          components.tests.kore-test.preCheck = ''
            export PATH="$PATH''${PATH:+:}${lib.getBin pkgs.z3}/bin"
          '';
        };
      }
    ];
  };

  shell = import ./shell.nix { inherit default checkMaterialization; };

  version = builtins.trace (builtins.attrNames project.kore.components.exes) project.kore.components.exes.kore-exec.version;
  # version = "0.43.0.0";

  prelude-kore = ./src/main/kore/prelude.kore;

  rematerialize = pkgs.writeScript "rematerialize.sh" ''
    #!/bin/sh
    ${project.stack-nix.passthru.updateMaterialized}
  '';

  default =
    {
      inherit pkgs prelude-kore project rematerialize;
      cache = [
        project.roots
        (pkgs.haskell-nix.withInputs shell)
      ];

      kore = pkgs.symlinkJoin {
        name = "kore-${version}";
        paths = pkgs.lib.attrValues project.kore.components.exes;
      };

      # Change the compiler when updating our own resolver.
      compiler-nix-name = "ghc8104";
      index-state = "2021-02-09T00:00:00Z";
    };

in default
