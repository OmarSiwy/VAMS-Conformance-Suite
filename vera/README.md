# vera/

What only [VerA](https://github.com/OmarSiwy/VerA) uses. VerA checks this
suite out at `tests/conformance` and runs `tests/` through its own harness
(`zig build test-ams`, `test-devices`, `test-1364`, `test-vpi`, `test-spice`);
`conform` never reads this directory, since a test is a file under `tests/`.

| Path | Contents |
|---|---|
| `host/` | Zig hosts that load an emitted device and drive it: `*_host.zig`, the `*_gpu.zig` twin, `*_dyn.zig`, `vdev_*.zig`, `vpi_host.zig`. Each names its device with `//! device tests/<lang>/<chapter>/<file>`, a suite-relative path |
| `canary/` | Wrong-on-purpose fixtures that VerA's harness must FAIL, and `EXPECT.tsv`, the verdict each one must get |
| `ledger/` | The evidence accounting: `VERDICTS.tsv` and `LEVELS.tsv` (the verdict and evidence-level baselines), `OBLIGATIONS.tsv` (the AMS sentence ledger), `SPECIALIZED.tsv` (host, VPI and reference assertions), `ORACLES.tsv`, `GAPS.tsv`, `FEATURE_GAPS.tsv`, `MUTANTS.tsv`, `ICARUS.tsv`, `GRAMMAR.tsv`, `GRAMMAR-DIFF.tsv`, `ADVERSARIAL.tsv`, `PROFILES.json` and `STEPS.txt` |
| `clauses/<chapter>/CLAUSES.tsv` | Per-chapter clause classification rows (`ieee1364/` for IEEE 1364-2005); metadata, not tests |
| `rtlil/` | `--emit-rtlil` inputs, read by Yosys |
| `beh_verilog/` | `--emit-verilog` inputs and their testbenches |
| `osdi/` | ngspice decks over `--emit-osdi` models, described in `MANIFEST` |
| `external/` | The external analog suites' manifests and triage (`cmcqa`, `hicum-qa`, `va-models`, `vampyre`, `xyce`) |
| `ieee1364/` | Support scripts for a 1364 chapter (the protected-envelope vector check) |
| `xfail` | VerA's own expected failures under its harness |

## xfail

One test per line: its path relative to the suite root, then `#` and the
reason. Lines starting with `#` are comments.

```
tests/verilog/16_sdf/sdf_interconnect_delay.v # SDF annotation is not implemented; $sdf_annotate is refused with E1102.
```

A listed test that passes fails the run, so remove its line once VerA meets
the rule. This list is VerA's harness's; `tools/vera.xfail` is the `conform`
baseline for the same tool and is kept separately.
