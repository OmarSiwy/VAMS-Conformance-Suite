// D08 — CMOS switches: cmos and rcmos.
//
// Verilog-AMS 2.4 Annex A.3.4:
//     cmos_switchtype ::= cmos | rcmos
// Annex A.3.1:
//     cmos_switch_instance ::= [ name_of_gate_instance ]
//         ( output_terminal , input_terminal , ncontrol_terminal ,
//           pcontrol_terminal )
// §7.8.5.1: "For 4 port MOS switches (cmos, rcmos) the ports reading from left
// to right will be named source, drain, ngate, pgate." — ncontrol before
// pcontrol. §1.1 makes IEEE Std 1364-2005 clause 7 normative, where the cmos
// gate is DEFINED as an nmos and a pmos sharing their data and output
// terminals.
//
// HAND DERIVATION. Apply that definition literally, using the nmos/pmos tables
// already derived in switch_mos.v:
//
//     cmos(data, nc, pc) = combine( nmos(data, nc), pmos(data, pc) )
//
// The nmos arm conducts on nc=1, the pmos arm on pc=0, and combining two
// equal-strength drivers of which at most one is non-z is just "whichever is
// not z". So the only control pair that isolates the output is nc=0 AND pc=1
// — the pair that turns BOTH transistors off:
//
//     nc pc | nmos arm   pmos arm   cmos
//     0  0  |   z          data     data
//     0  1  |   z          z        z        <- the only z row
//     1  0  |   data       data     data     (both arms agree, no conflict)
//     1  1  |   data       z        data
//
// and passing data means passing it as a connection, so data=z gives z and
// data=x gives x. That is why the d=1 row reads 1, z, 1, 1 and not 1, z, x, 1:
// at nc=1,pc=0 both transistors conduct the SAME value, which resolves to that
// value rather than to a conflict. A compiler that treats the two arms as two
// independent drivers and conflicts them fails exactly those four rows.
//
// rcmos differs only in output strength, never in value, so every rcmos column
// equals its cmos column here.
//
//! lrm A.3.1
//! lrm A.3.4
//! lrm 1.1
//! lrm 7.8.5.1
//! lrm A.3.1:1000
//! lrm A.3.4:1000
//! inherited IEEE 1364-2005 7.7
`timescale 1ns/1ns
module d08_switch_cmos;
  reg d, nc, pc;
  wire w_cmos, w_rcmos;

  cmos  c0 (w_cmos,  d, nc, pc);
  rcmos c1 (w_rcmos, d, nc, pc);

  initial begin
    d = 1'b0; nc = 1'b0; pc = 1'b0; #1
      $display("d=0 nc=0 pc=0 got cmos=%b rcmos=%b want 0 0", w_cmos, w_rcmos);
    d = 1'b0; nc = 1'b0; pc = 1'b1; #1
      $display("d=0 nc=0 pc=1 got cmos=%b rcmos=%b want z z", w_cmos, w_rcmos);
    d = 1'b0; nc = 1'b1; pc = 1'b0; #1
      $display("d=0 nc=1 pc=0 got cmos=%b rcmos=%b want 0 0", w_cmos, w_rcmos);
    d = 1'b0; nc = 1'b1; pc = 1'b1; #1
      $display("d=0 nc=1 pc=1 got cmos=%b rcmos=%b want 0 0", w_cmos, w_rcmos);
    d = 1'b1; nc = 1'b0; pc = 1'b0; #1
      $display("d=1 nc=0 pc=0 got cmos=%b rcmos=%b want 1 1", w_cmos, w_rcmos);
    d = 1'b1; nc = 1'b0; pc = 1'b1; #1
      $display("d=1 nc=0 pc=1 got cmos=%b rcmos=%b want z z", w_cmos, w_rcmos);
    d = 1'b1; nc = 1'b1; pc = 1'b0; #1
      $display("d=1 nc=1 pc=0 got cmos=%b rcmos=%b want 1 1", w_cmos, w_rcmos);
    d = 1'b1; nc = 1'b1; pc = 1'b1; #1
      $display("d=1 nc=1 pc=1 got cmos=%b rcmos=%b want 1 1", w_cmos, w_rcmos);
    d = 1'bx; nc = 1'b0; pc = 1'b0; #1
      $display("d=x nc=0 pc=0 got cmos=%b rcmos=%b want x x", w_cmos, w_rcmos);
    d = 1'bx; nc = 1'b0; pc = 1'b1; #1
      $display("d=x nc=0 pc=1 got cmos=%b rcmos=%b want z z", w_cmos, w_rcmos);
    d = 1'bx; nc = 1'b1; pc = 1'b0; #1
      $display("d=x nc=1 pc=0 got cmos=%b rcmos=%b want x x", w_cmos, w_rcmos);
    d = 1'bx; nc = 1'b1; pc = 1'b1; #1
      $display("d=x nc=1 pc=1 got cmos=%b rcmos=%b want x x", w_cmos, w_rcmos);
    d = 1'bz; nc = 1'b0; pc = 1'b0; #1
      $display("d=z nc=0 pc=0 got cmos=%b rcmos=%b want z z", w_cmos, w_rcmos);
    d = 1'bz; nc = 1'b0; pc = 1'b1; #1
      $display("d=z nc=0 pc=1 got cmos=%b rcmos=%b want z z", w_cmos, w_rcmos);
    d = 1'bz; nc = 1'b1; pc = 1'b0; #1
      $display("d=z nc=1 pc=0 got cmos=%b rcmos=%b want z z", w_cmos, w_rcmos);
    d = 1'bz; nc = 1'b1; pc = 1'b1; #1
      $display("d=z nc=1 pc=1 got cmos=%b rcmos=%b want z z", w_cmos, w_rcmos);
  end
endmodule
