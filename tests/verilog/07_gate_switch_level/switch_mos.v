// D08 — MOS switches: nmos, pmos and the resistive rnmos, rpmos.
//
// Verilog-AMS 2.4 Annex A.3.4:
//     mos_switchtype ::= nmos | pmos | rnmos | rpmos
// Annex A.3.1:
//     mos_switch_instance ::= [ name_of_gate_instance ]
//         ( output_terminal , input_terminal , enable_terminal )
// §7.8.5.1: "For 3 port MOS switches (nmos, pmos, rnmos, rpmos) the ports
// reading from left to right will be named source, drain, gate." — the gate
// (enable) terminal is last. §1.1 makes IEEE Std 1364-2005 clause 7 normative.
//
// HAND DERIVATION, AND THE ONE CELL THAT MATTERS. An nmos conducts when its
// gate is 1, a pmos when its gate is 0. When it conducts it is a CONNECTION,
// not a logic function, and that is the whole difference from bufif1/bufif0 in
// gates_enable.v:
//
//   data = z, gate = 1 :  bufif1 -> x   (a gate coerces z on its input to x)
//                         nmos   -> z   (a switch transmits the z through)
//
// Those four `d=z` rows at the bottom are therefore the discriminating rows of
// this fixture. Whatever the gate does, a z input yields z: if the switch is on
// it passes z, if it is off the output is z, and if conduction is unknown both
// possibilities are z, so there is nothing ambiguous to report.
//
// The rest:
//   gate = off value  -> z.
//   gate = on  value  -> the data value verbatim (including x).
//   gate = x or z     -> conduction is unknown, so the output is "data or z":
//                        IEEE 1364's L (0-or-z) for data 0 and H (1-or-z) for
//                        data 1, neither of which is in {0,1,x,z}; the sound
//                        four-state projection is x. For data x it is x anyway.
//
// The r- variants are here to pin that RESISTIVE switches change the STRENGTH
// and never the VALUE: every rnmos cell equals its nmos cell and every rpmos
// cell equals its pmos cell. The strength half is pinned separately in
// strength_reduction.v, where the reduction becomes visible as a value.
//
//! lrm A.3.1
//! lrm A.3.4
//! lrm 1.1
//! lrm 7.8.5.1
//! lrm A.3.1:1000
//! lrm A.3.4:1000
//! inherited IEEE 1364-2005 7.5
`timescale 1ns/1ns
module d08_switch_mos;
  reg d, g;
  wire w_nmos, w_pmos, w_rnmos, w_rpmos;

  nmos  s0 (w_nmos,  d, g);
  pmos  s1 (w_pmos,  d, g);
  rnmos s2 (w_rnmos, d, g);
  rpmos s3 (w_rpmos, d, g);

  initial begin
    d = 1'b0; g = 1'b0; #1
      $display("d=0 g=0 got nmos=%b pmos=%b rnmos=%b rpmos=%b want z 0 z 0",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'b0; g = 1'b1; #1
      $display("d=0 g=1 got nmos=%b pmos=%b rnmos=%b rpmos=%b want 0 z 0 z",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'b0; g = 1'bx; #1
      $display("d=0 g=x got nmos=%b pmos=%b rnmos=%b rpmos=%b want x x x x",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'b0; g = 1'bz; #1
      $display("d=0 g=z got nmos=%b pmos=%b rnmos=%b rpmos=%b want x x x x",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'b1; g = 1'b0; #1
      $display("d=1 g=0 got nmos=%b pmos=%b rnmos=%b rpmos=%b want z 1 z 1",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'b1; g = 1'b1; #1
      $display("d=1 g=1 got nmos=%b pmos=%b rnmos=%b rpmos=%b want 1 z 1 z",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'b1; g = 1'bx; #1
      $display("d=1 g=x got nmos=%b pmos=%b rnmos=%b rpmos=%b want x x x x",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'b1; g = 1'bz; #1
      $display("d=1 g=z got nmos=%b pmos=%b rnmos=%b rpmos=%b want x x x x",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'bx; g = 1'b0; #1
      $display("d=x g=0 got nmos=%b pmos=%b rnmos=%b rpmos=%b want z x z x",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'bx; g = 1'b1; #1
      $display("d=x g=1 got nmos=%b pmos=%b rnmos=%b rpmos=%b want x z x z",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'bx; g = 1'bx; #1
      $display("d=x g=x got nmos=%b pmos=%b rnmos=%b rpmos=%b want x x x x",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'bx; g = 1'bz; #1
      $display("d=x g=z got nmos=%b pmos=%b rnmos=%b rpmos=%b want x x x x",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'bz; g = 1'b0; #1
      $display("d=z g=0 got nmos=%b pmos=%b rnmos=%b rpmos=%b want z z z z",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'bz; g = 1'b1; #1
      $display("d=z g=1 got nmos=%b pmos=%b rnmos=%b rpmos=%b want z z z z",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'bz; g = 1'bx; #1
      $display("d=z g=x got nmos=%b pmos=%b rnmos=%b rpmos=%b want z z z z",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
    d = 1'bz; g = 1'bz; #1
      $display("d=z g=z got nmos=%b pmos=%b rnmos=%b rpmos=%b want z z z z",
               w_nmos, w_pmos, w_rnmos, w_rpmos);
  end
endmodule
