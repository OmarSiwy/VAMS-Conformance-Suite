# xyce: triage

Every FAIL `tools/external_analog.py xyce` reports, one row per root cause
and one fnmatch pattern per row (the harness reads one backticked pattern
from the first cell). A pattern that names no FAIL turns `STALE`: delete the
row.

Verdicts:

- `vera-correct`: VerA follows the LRM; the model's source does not.
- `out-of-scope`: not a question about either tool (a mirror's edit).
- `reference`: Xyce's built-in model is not what the Verilog-A source computes on this card; VerA agrees with openvaf-r where openvaf-r runs.
- `unresolved`: VerA and Xyce disagree slightly and no third opinion settles it; the reason says by how much.

Measured against `vera` at 4887c2dc plus the external-analog timeout fix,
Xyce 7.10.0, on 2026-10-19 (17 PASS, 12 FAIL).

| names | verdict | reason |
|---|---|---|
| `xyce/bsim4/compile/vera` | vera-correct | the same refusal as `va-models/bsim4/compile/vera` (E0138, a string literal continued across lines) |
| `xyce/mextram/compile/vera` | out-of-scope | the same mirror edit as `va-models/mextram/compile/vera` (`IPRnb` defined only under `__OPENVAF__`) |
| `xyce/vbic/[!c]*` | reference | Xyce's level-12 VBIC on the VA-Models card does not behave as a forward-biased transistor: 1.23 mA of base current at Vbe = 0.3 V and -4.8 mA of substrate current at 1 V, where VerA's library gives picoamperes; the card's parameters do not reach Xyce's model as they reach the Verilog-A |
| `xyce/psp103/[!c]*` | reference | Xyce's PSP103 gives a tenth of VerA's subthreshold drain current at Vg = -0.2 V (1.1e-13 A against 1.2e-12 A); VerA agrees with openvaf-r on the same dcIdVg test (`va-models/psp103/dcIdVg` passes) |
| `xyce/hicum2/[!c]*` | unresolved | dcOutput is 6e-6 (I(c)) and 8.5e-5 (I(b) at 9.6e-9 A) off Xyce's HICUM 2.4.0; dcGummel differs only within a decade of the 1e-13 A clip (I(b) changes sign at 1e-13 A) |
