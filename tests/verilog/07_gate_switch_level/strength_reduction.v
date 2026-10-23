// D08 — pullup/pulldown sources, drive strengths, and strength reduction
// through the resistive (r-) switches, made visible as a four-state VALUE.
//
// Verilog-AMS 2.4 Annex A.3.1:
//     | pulldown [pulldown_strength] pull_gate_instance { , ... } ;
//     | pullup   [pullup_strength]   pull_gate_instance { , ... } ;
//     pull_gate_instance ::= [ name_of_gate_instance ] ( output_terminal )
// Annex A.2.2.2:
//     drive_strength ::= ( strength0 , strength1 ) | ( strength1 , strength0 )
//                      | ( strength0 , highz1 )   | ( strength1 , highz0 )
//                      | ( highz0 , strength1 )   | ( highz1 , strength0 )
//     strength0 ::= supply0 | strong0 | pull0 | weak0
//     strength1 ::= supply1 | strong1 | pull1 | weak1
// §7.8.5.1: "For single port primitives (pullup, pulldown) the port will be
// named out." §1.1 makes IEEE Std 1364-2005 clause 7 — logic strength
// modelling, strength reduction by non-resistive and by resistive devices —
// the normative rules for everything asserted below.
//
// THE POINT OF THIS FIXTURE. A strength model that is merely stored and never
// consulted is indistinguishable from no strength model at all, so nothing here
// asserts a strength directly. Each net below is a CONTEST between two drivers
// whose winner is decided by strength alone, and the contest's outcome is an
// ordinary %b column. A build with no strength lattice cannot reproduce the
// distinct `wn` and `wr` outcomes in row 2 below. Current implementation
// limitations are recorded in docs/conformance-ieee-primitives-review.md at 8b1514d4, not
// inferred from this source-derived expectation.
//
// THE LATTICE, eight levels, strongest first:
//     supply(7) strong(6) pull(5) large(4) weak(3) medium(2) small(1) highz(0)
// A value read out of a variable is at strong strength; a gate's default output
// drive is (strong0, strong1); pullup drives pull1 and pulldown drives pull0.
// A non-resistive switch (nmos, pmos, cmos, tran, tranif) passes the input
// strength through unchanged EXCEPT supply becomes strong (IEEE 7.11).
// A resistive switch follows IEEE Table 7-8: supply/strong become pull,
// pull becomes weak, large/weak become medium, medium becomes small,
// and small/highz remain unchanged. This fixture exercises strong to pull.
// Two drivers of DIFFERENT strength: the stronger one's value wins outright.
// Two drivers of the SAME strength and opposite value: unresolvable, so x.
//
// ROW-BY-ROW DERIVATION.
//
//   wn = pullup + nmos(d, g)      wr = pullup + rnmos(d, g)
//
//   g=0 d=0 : both switches are off (highz). The pullup is the only driver on
//             each net.                                   -> wn=1   wr=1
//   g=1 d=0 : nmos passes the reg's strong 0. St0(6) vs Pu1(5): strong wins.
//             rnmos passes the same 0 but REDUCES strong to pull. Pu0(5) vs
//             Pu1(5): equal strength, opposite values, unresolvable.
//                                                         -> wn=0   wr=x
//             This is the discriminating row of the fixture. It fails both on a
//             compiler with no strength model (which would give x, x or 0, 0
//             depending on its conflict rule) and on one that implements
//             strengths but forgets that the r- prefix reduces.
//   g=1 d=1 : both switches pass a 1 and the pullup also pulls 1. Agreeing
//             drivers never conflict whatever their strengths. -> wn=1  wr=1
//   g=0 d=1 : switches off again, pullup alone.             -> wn=1   wr=1
//
//   wd = pulldown + bufif1(1'b1, en)
//   en=0 : the bufif1 is off (highz), pulldown alone.       -> wd=0
//   en=1 : bufif1 drives a strong 1. St1(6) beats Pu0(5).   -> wd=1
//
//   ww = pullup + buf (weak0, weak1) driving a constant 0
//   The explicit drive_strength makes that buf a We0(3) driver, which LOSES to
//   the pullup's Pu1(5). The net reads 1 even though a gate is actively driving
//   it to 0 — the reverse of the wd=1 row above, so the two rows together pin
//   that the winner is chosen by the lattice and not by "a gate beats a pull".
//                                                           -> ww=1
//
//! lrm A.3.1
//! lrm A.2.2.2
//! lrm 1.1
//! lrm 7.8.5.1
//! lrm A.2.2.2:1000
//! inherited IEEE 1364-2005 7.1.2 7.8 7.10.1 7.11 7.12
`timescale 1ns/1ns
module d08_strength_reduction;
  reg d, g, en;
  wire wn, wr, wd, ww;

  pullup pu_n (wn);
  pullup pu_r (wr);
  nmos   n1   (wn, d, g);
  rnmos  r1   (wr, d, g);

  pulldown pd_d (wd);
  bufif1   b1   (wd, 1'b1, en);

  pullup pu_w (ww);
  buf (weak0, weak1) bw (ww, 1'b0);

  initial begin
    d = 1'b0; g = 1'b0; #1
      $display("g=0 d=0 got wn=%b wr=%b want 1 1", wn, wr);
    d = 1'b0; g = 1'b1; #1
      $display("g=1 d=0 got wn=%b wr=%b want 0 x", wn, wr);
    d = 1'b1; g = 1'b1; #1
      $display("g=1 d=1 got wn=%b wr=%b want 1 1", wn, wr);
    d = 1'b1; g = 1'b0; #1
      $display("g=0 d=1 got wn=%b wr=%b want 1 1", wn, wr);

    en = 1'b0; #1
      $display("en=0 got wd=%b want 0", wd);
    en = 1'b1; #1
      $display("en=1 got wd=%b want 1", wd);

    $display("weak driver vs pullup got ww=%b want 1", ww);
  end
endmodule
