// D10 x D03. The one part of IEEE Std 1364 §19.9 that the analog kernel
// CANNOT express, written for the digital source-execution path instead.
//
// §10.1 Table 10-1 carries `unconnected_drive over from IEEE Std 1364, where it
// pulls an unconnected input port to a logic level THROUGH A PULL-STRENGTH
// DRIVER. ch10_directives/58, 59 and 60 pin the level and say in their own
// headers why that is the weak half — 58, quoted exactly: "WHAT A PULL IS IN
// THE ANALOG KERNEL, since §19.9 describes a logic level and a drive
// STRENGTH, and this engine has neither." So those three fixtures approximate
// the pull as a potential source at 1 V or 0 V, and `lib/ir/lower.zig`
// (`applyUnconnectedDrive`) records the same approximation as its stated
// ceiling.
//
// The approximation is invisible as long as the pull is the ONLY driver of the
// port's net. It stops being invisible the moment the net has a second opinion,
// and that is the entire content of this file: on a four-state net the pull
// competes, and IEEE 1364 §7.9's eight drive strengths decide who wins (§7.10 combines them).
//
// STRENGTH LEVELS, which are what the three answers below are computed from:
//
//     supply 7 > strong 6 > PULL 5 > large 4 > weak 3 > medium 2 > small 1 > highz 0
//
// One child, three unconnected input ports, one `unconnected_drive pull1 region
// over the module definition. Each port declares a different net type, so each
// meets the Pu1 driver with a different opponent:
//
//   w   wire     — no second driver at all. The net's own undriven value is Z,
//                  which is the identity of IEEE 1364 §7.10's resolution of combined signals,
//                  so the only driver decides: Pu1 -> the net reads 1.
//   t   tri0     — IEEE 1364 §4.6.4: a `tri0` net pulls itself to 0 AT PULL
//                  STRENGTH when nothing else drives it. So the net has Pu0
//                  against Pu1: equal strength, opposite values, and IEEE 1364
//                  §7.10 resolves that to X. This is the case no approximation
//                  can reach — a potential source cannot produce an X.
//   s   supply0  — IEEE 1364 §4.6.6/§7.13: a supply net drives at SUPPLY strength,
//                  level 7, which is two levels above the pull. Su0 beats Pu1
//                  and the net reads 0 — the directive is honoured and still
//                  loses.
//
// EXPECTED OUTPUT, one line, `11_..._expected.txt`:
//
//     w=1 t=x s=0
//
// The three answers come from one directive and differ only by net type, which
// is what makes any of them discriminating: a tool with no strength model at
// all prints `w=1 t=x s=x` if it resolves every disagreement to X, or
// `w=1 t=0 s=0` if the declared net type simply wins, and neither matches.
//
// WHY THIS IS NOT A .va FIXTURE. The values above are logic values on discrete
// nets. `Lower.applyUnconnectedDrive` skips any net whose discipline binds no
// potential — "there is nothing to hold it at" — so the analog harness has no
// way to observe them, and `V()` on a discrete net is E0501, not a number.
//
// It runs and passes: the digital runner (`src/sim/digital/`) elaborates the
// child, applies the preprocessor's `DriveRegion` list to the unconnected
// inputs as pull-strength drivers, and resolves them with §7.10's strength
// model. (Until that landed this header listed three blockers; they are gone.)

//! inherited IEEE 1364-2005 4.6.4 4.6.6 7.10.1 19.9
`unconnected_drive pull1
module d10_pulled(w, t, s);
  input w;
  input t;
  input s;
  wire    w;   // Z vs Pu1        -> 1
  tri0    t;   // Pu0 vs Pu1      -> x   (equal strength, opposite value)
  supply0 s;   // Su0 vs Pu1      -> 0   (supply outranks pull)
endmodule
`nounconnected_drive

module d10_unconnected_drive_pull_meets_the_strength_model;
  d10_pulled u( , , );
  // #1: at t=0 the read races the pulls' own time-0 evaluation (11.5).
  initial #1 $display("w=%b t=%b s=%b", u.w, u.t, u.s);
endmodule
