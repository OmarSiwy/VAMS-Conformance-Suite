# vampyre: triage

Every disagreement `tools/external_vampyre.py` reports, one row per root
cause. A row's one fnmatch pattern names exactly the disagreements it covers, so a new
disagreement is never swallowed by an old row, and a name that stops
disagreeing turns its pattern `STALE`: delete it, and the row with its last
pattern.

Verdicts, judged by the Verilog-AMS LRM, never by either tool's say-so:

- `vera-bug`: VerA is wrong (a missed or false finding, or refusing legal source).
- `vera-correct`: VerA follows the LRM; VAMPyRE's finding or the model's source does not.
- `vampyre-miss`: the finding is real by the LRM and VAMPyRE does not report it.
- `out-of-scope`: not a question about either tool (a mirror's edit, a model that only compiles under another simulator's macros).

Measured against `vera` at 79f0e220 plus this change, VAMPyRE at d0acfc4b, on 2026-10-17.

| names | verdict | reason |
|---|---|---|
| `va-models/bsim4/compile` | vera-correct | §2.7: "a string literal ... contained on a single line"; this BSIM4 continues sixteen `$strobe` strings with a trailing backslash (an IEEE 1800 §5.9 continuation), which VerA refuses as E0138 |
| `va-models/mextram/compile` | out-of-scope | VA-Models' frontdef.inc defines `IPRnb` only under `` `ifdef __OPENVAF__`` (the mirror's edit), so any other compiler meets an undefined macro (E0115); the upstream Mextram 504.8 compiles (`cmcqa/mextram504*`) |
| `cmcqa/r[23]/compile` | vera-correct | A.6.4: `` `WARNING(str)`` expands to `$strobe(str);` and every use adds its own `;`, a null statement inside a sequential block, whose item list (`analog_seq_block`) holds no null statement (E0219). R3_CMC 1.1.2 drops the extra `;` and compiles |
| `cmcqa/mextram*504*/hidden/Iqs` | vampyre-miss | §3.2: evaluate.inc assigns `Iqs` only when `Ic1c2 > 0.0`, and opinfo.inc reads it on every evaluation (`OP_iqs = Iqs;`), so at `Ic1c2 <= 0` the read sees the previous evaluation's value. VerA holds it (`retained`); VAMPyRE does not report it |
