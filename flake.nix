{
  description = "Verilog-AMS conformance suite: tests, the conform harness, and the reference tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      lib = nixpkgs.lib;

      conform =
        { stdenv }:
        stdenv.mkDerivation {
          pname = "conform";
          version = "0.1.0";
          src = ./harness;
          buildPhase = "$CC -std=c99 -O2 -Wall -Wextra -o conform conform.c -lm";
          installPhase = "install -Dm755 conform $out/bin/conform";
          meta.mainProgram = "conform";
        };

      # OpenVAF-Reloaded: a Verilog-A compiler to OSDI, not in nixpkgs. The
      # release is an x86_64-linux binary.
      openvaf-r =
        {
          stdenv,
          fetchurl,
          autoPatchelfHook,
          llvmPackages_18,
        }:
        stdenv.mkDerivation rec {
          pname = "openvaf-reloaded";
          version = "24.0.2mob";
          src = fetchurl {
            url = "https://github.com/OpenVAF/OpenVAF-Reloaded/releases/download/v${version}/openvaf-r-v${version}-linux-x86_64.tar.gz";
            hash = "sha256-sSt7FybRA+GMJYjDofkfhHXPA9+KO94U2Rl5fSIeMRA=";
          };
          nativeBuildInputs = [ autoPatchelfHook ];
          buildInputs = [
            llvmPackages_18.libllvm
            stdenv.cc.cc.lib
          ];
          installPhase = ''
            install -Dm755 bin/openvaf-r $out/bin/openvaf-r
            ln -s openvaf-r $out/bin/openvaf
          '';
          meta = {
            homepage = "https://github.com/OpenVAF/OpenVAF-Reloaded";
            platforms = [ "x86_64-linux" ];
            mainProgram = "openvaf-r";
          };
        };

      packagesFor = pkgs: {
        conform = pkgs.callPackage conform { };
        openvaf-r = pkgs.callPackage openvaf-r { };
      };
    in
    {
      overlays.default = final: _: packagesFor final;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        built = packagesFor pkgs;
        available = lib.filter (p: lib.meta.availableOn pkgs.stdenv.hostPlatform p);
      in
      {
        packages = lib.filterAttrs (_: p: lib.meta.availableOn pkgs.stdenv.hostPlatform p) built // {
          default = built.conform;
        };

        devShells.default = pkgs.mkShell {
          packages = available [
            built.conform
            built.openvaf-r
            pkgs.ngspice
            pkgs.iverilog
            pkgs.verilator
            pkgs.python3
          ];
        };

        checks.selftest = pkgs.runCommand "conform-selftest" { nativeBuildInputs = [ built.conform ]; } ''
          sh ${./harness/selftest.sh} conform
          touch $out
        '';

        formatter = pkgs.nixfmt;
      }
    );
}
