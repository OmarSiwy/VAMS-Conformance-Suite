# hicum-qa: triage

Every FAIL `tools/external_analog.py hicum-qa` reports, one row per root
cause and one fnmatch pattern per row (the harness reads one backticked
pattern from the first cell). A pattern that names no FAIL turns `STALE`:
delete the row.

Verdicts:

- `reference`: the published reference is not what the model's source computes in ngspice: openvaf-r's library of the same source disagrees with it the same way.

Measured against `vera` at 4887c2dc plus the external-analog timeout fix, on
2026-10-19 (17 PASS, 647 FAIL).

| names | verdict | reason |
|---|---|---|
| `hicum-qa/hicumL2V2p4p0/[!c]*` | reference | TU Dresden's results are not what VA-Models' hicumL2V2p4p0.va computes under this deck: on every test openvaf-r's library of the same file can run (the parameter sets with self-heating or a substrate network: `full_sh`, `full_sub*`, `cornoise`), its worst relErr equals VerA's to three digits (CBC_CCS dc 0.00395, CBE ac 0.000828, fout 0.0532, ypara ac 0.046, vce_0 0.333); on the rest openvaf-r's library is singular at the thermal node. The fgum_dc tests also read 39 sweep points per curve where the CMC sweep rule gives 38: the results include the stop value 1.05 V, which the 0.02 V step does not reach |
