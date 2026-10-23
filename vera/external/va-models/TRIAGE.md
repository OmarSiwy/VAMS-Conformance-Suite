# va-models: triage

Every FAIL `tools/external_analog.py va-models` reports, one row per root
cause and one fnmatch pattern per row (the harness reads one backticked
pattern from the first cell). `[!c]*` keeps a model's `compile/` names out
of a row about its simulations, so a new FAIL is never swallowed by an old
row, and a pattern that names no FAIL turns `STALE`: delete the row.

Verdicts, judged by the Verilog-AMS LRM and by the model's own source, never
by either tool's say-so:

- `vera-bug`: VerA is wrong.
- `vera-correct`: VerA follows the LRM; the model's source or the other tool does not.
- `reference`: the reference side fails or is wrong (here: openvaf-r's library of the same source cannot run the test), so there is nothing to compare VerA against.
- `out-of-scope`: not a question about either tool (a mirror's edit).
- `unresolved`: VerA and openvaf-r both run and disagree; the reason says by how much. Which one is right is not yet known.

Measured against `vera` at 4887c2dc plus the external-analog timeout fix, on
2026-10-19 (61 FAIL).

| names | verdict | reason |
|---|---|---|
| `va-models/bsim4/compile/vera` | vera-correct | §2.7: "a string literal ... contained on a single line"; this BSIM4 continues sixteen `$strobe` strings with a trailing backslash (an IEEE 1800 §5.9 continuation), which VerA refuses as E0138 |
| `va-models/mextram/compile/vera` | out-of-scope | VA-Models' frontdef.inc defines `IPRnb` only under `` `ifdef __OPENVAF__`` (the mirror's edit), so any other compiler meets an undefined macro (E0115); the upstream Mextram 504.8 compiles (`cmcqa/mextram504*`) |
| `va-models/bsimcmg/[!c]*` | reference | openvaf-r's library is singular at the thermal node (`check node t`, `t_g`): with self-heating off the node has nothing attached in its library. VerA's library runs every test |
| `va-models/hicum2/[!ct]*` | reference | openvaf-r's library is singular at the thermal node (`check node t`, `t_b`), as for BSIM-CMG. VerA's library runs dcGummel, dcOutput, acY and noiseIc |
| `va-models/vbic/[!ct]*` | reference | openvaf-r's library is singular at the internal collector (`check node n1#ci`) or fails its transient op; VerA's runs |
| `va-models/[hv]*/tranBase/*` | unresolved | VerA's library passes the operating point but ngspice's transient step collapses at the pulse edge ("Timestep too small ... node v_s#branch"); it completes under ngspice's default abstol (1e-12), and openvaf-r's library fails earlier (singular, or no transient op) |
| `va-models/psp103/noiseSat/N(d)` | unresolved | VerA's drain noise PSD is 1.85% under openvaf-r's at 1 GHz; every PSP103 DC, AC and transient output agrees |
| `va-models/r2_cmc/[!c]*` | unresolved | VerA and openvaf-r differ by 7e-4 (dcPoly at -9.9 V) and 1.7e-4 (noise); R2_CMC's nonlinearity at high field |
| `va-models/r3_cmc/[!c]*` | unresolved | VerA and openvaf-r differ by 1.6e-4 to 7e-3 on DC (dcWeakDp, dcStrongVsat, dcSelfHeating) and 2% on acParasitics; the upstream R3 1.0.0 does not compile in VerA (`cmcqa/r3`), so the CMC references cannot settle it |
