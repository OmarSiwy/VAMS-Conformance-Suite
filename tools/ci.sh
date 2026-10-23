#!/usr/bin/env bash
# Fetch the latest TOOL, run it over every test and manifest, and leave
# results/TOOL.tsv and results/TOOL.version. Needs Nix with flakes; run from
# the repository root with submodules checked out.
#   tools/ci.sh vera|openvaf|iverilog|verilator|ngspice|espice
#
# "Latest" means: VerA and ESPice at their default branch's HEAD, OpenVAF-
# Reloaded at its newest GitHub release, the rest at nixpkgs-unstable.
set -euo pipefail
tool=${1:?usage: tools/ci.sh TOOL}
mkdir -p results
nix build .#conform -o result-conform
export PATH=$PWD/result-conform/bin:$PATH
unstable=github:NixOS/nixpkgs/nixpkgs-unstable
paths=(tests external/*.manifest)
in_shell=(nix shell "$unstable#python3")

case $tool in
vera)
  nix build github:OmarSiwy/VerA -o result-tool
  export VERA=$PWD/result-tool/bin/vera
  # vera drives Zig at run time: run inside VerA's own dev shell.
  in_shell=(nix develop github:OmarSiwy/VerA)
  version=$("$VERA" --version)
  ;;
espice)
  nix build github:OmarSiwy/ESPice -o result-tool
  export ESPICE=$PWD/result-tool/bin/espice
  version="espice $("$ESPICE" --version 2>&1 | head -1)"
  ;;
openvaf)
  # The flake's openvaf-r, with its source swapped for the newest release.
  tag=$(curl -sSfL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} https://api.github.com/repos/OpenVAF/OpenVAF-Reloaded/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')
  url=https://github.com/OpenVAF/OpenVAF-Reloaded/releases/download/$tag/openvaf-r-$tag-linux-x86_64.tar.gz
  nix build --impure -o result-tool --expr "(builtins.getFlake \"path:$PWD\").packages.x86_64-linux.openvaf-r.overrideAttrs (_: { version = \"$tag\"; src = builtins.fetchurl \"$url\"; })"
  in_shell=(nix shell "$unstable#python3" "$unstable#ngspice" "$PWD/result-tool")
  version="openvaf-r $tag"
  ;;
iverilog | verilator | ngspice)
  in_shell=(nix shell "$unstable#python3" "$unstable#$tool")
  case $tool in
  iverilog) version=$("${in_shell[@]}" -c iverilog -V 2>&1 | head -1) ;;
  verilator) version=$("${in_shell[@]}" -c verilator --version) ;;
  ngspice) version=$("${in_shell[@]}" -c ngspice --version | grep -m1 ngspice) ;;
  esac
  ;;
*)
  echo "unknown tool $tool" >&2
  exit 2
  ;;
esac

echo "$version" > "results/$tool.version"
# conform exits 1 on any FAIL: that is the measurement, not an error here.
"${in_shell[@]}" -c conform -t "tools/$tool.conf" -j "$(nproc)" -T 120 -o "results/$tool.tsv" "${paths[@]}" > "results/$tool.log" || true
tail -3 "results/$tool.log"
