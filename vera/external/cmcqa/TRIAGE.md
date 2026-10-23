# cmcqa: triage

Every FAIL `tools/external_analog.py cmcqa` reports, one row per root cause
and one fnmatch pattern per row (the harness reads one backticked pattern
from the first cell). A pattern that names no FAIL turns `STALE`: delete the
row.

Verdicts, judged by the Verilog-AMS LRM and by the model's own source, never
by either tool's say-so:

- `vera-bug`: VerA is wrong.
- `vera-correct`: VerA follows the LRM; the model's source does not.
- `reference`: the published reference is not what the model's source computes: openvaf-r's library of the same source disagrees with it the same way.
- `unresolved`: VerA disagrees with the reference and no second compiler can settle it (openvaf-r refuses the upstream Mextram 504.8 source); the reason says by how much.

A reference printed to k significant digits is matched to k digits (the
harness's `Printed`), so a rounding of the print is never a FAIL.

Measured against `vera` at 4887c2dc plus the external-analog timeout fix, on
2026-10-19 (257 PASS, 107 FAIL).

| names | verdict | reason |
|---|---|---|
| `cmcqa/r[23]/compile/vera` | vera-correct | A.6.4: `` `WARNING(str)`` expands to `$strobe(str);` and every use adds its own `;`, a null statement inside a sequential block, whose item list (`analog_seq_block`) holds no null statement (E0219). R3_CMC 1.1.2 drops the extra `;` and compiles |
| `cmcqa/mosvar/[!c]*` | reference | openvaf-r's library of the same mosvar.va gives the same worst relErr against the reference: acvg 3.31e-5 and acfreq 4.43e-5 to three digits, igvg 0.0059 (VerA 0.0058); the gate tunneling currents and the 2 GHz Q are not what the 1.2.0 source computes |
| `cmcqa/mextram*504/ac[BN]*` | vera-bug | Without self-heating (bjt504, bjtd504) ngspice finds the AC system singular at VerA's internal base or collector node (`check nodes n1_b#b2 and v_s_b#branch`, `n1#c2`) after the operating point converged; a real Mextram keeps rbv/rcv across b2 and c2, and the same tests run on the self-heating variants |
| `cmcqa/mextram*/acFreq_*` | unresolved | Every variant's capacitances (C(b,c), C(c,b), C(c,c), C(b,b)) sit 2e-6 to 2e-5 off a reference printed to 15 digits, at 1 MHz to 1 GHz; the conductances of the same tests pass |
| `cmcqa/mextram*504t/acBias_*` | unresolved | The self-heating variants' capacitances sit 9e-6 to 5e-5 off the reference along the bias sweep; their conductances pass |
| `cmcqa/mextram*504t/acNoise_*` | unresolved | The self-heating variants' collector noise is 3% to 50% over the reference (bjt504t standT 1.5x at every bias) or singular at node b2 (bjt504t hightT) |
| `cmcqa/mextram*/Zener_Ib_*` | unresolved | The reverse base current in Zener breakdown is 8e-6 to 5e-5 off a 5-digit reference, past its rounding; the result does not move with reltol 1e-12, so it is the converged answer |
