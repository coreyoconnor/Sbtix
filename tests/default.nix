{ pkgs ? import <nixpkgs> {} }:
with pkgs.lib;
let
  sbtix = import ./../default.nix { inherit pkgs; };
  testPrefix = ''
    set -euxo pipefail

    cd "$(dirname "$0")"

    export PATH=${sbtix}/bin:$PATH

    function clean-test-dir() {
      for f in {,project/}repo.nix; do
        if [[ -e "$f" ]]; then
          rm "$f"
        fi
      done
    }
  '';
  runTest = testName:
    let
      runScriptPath = "${testName}/run.sh"
      runScript = pkgs.substituteAll {
        src = runScriptPath;
        inherit sbtix;
        inherit (pkgs) runtimeShell;
      };
    in pkgs.runCommand {
      name = "test-${testName}";
    } runScript;
in rec {
  # TODO: reference sbtix plugin tests
  template-generation = runTest "template-generation";
  multi-build =  runTest "multi-build";
  all = runTests [ template-generation multi-build ];
}
