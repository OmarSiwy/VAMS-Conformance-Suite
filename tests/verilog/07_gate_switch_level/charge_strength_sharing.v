// IEEE 1364-2005 §7.13.2, p. 100: "The strength of the drive resulting from a
// trireg net that is in the charge storage state (that is, a driver charged
// the net and then went to high impedance) shall be one of these three
// strengths: large, medium, or small. The specific strength associated with a
// particular trireg net shall be specified by the user in the net
// declaration. The default shall be medium."
// §4.6.3.1, p. 29 (Figure 4-2): connecting two trireg nets in the capacitive
// state "causes the smaller trireg net to store the value of the larger
// trireg net", and triregs of "the same size and stored different values"
// both "change value to x".
//
// Four pairs of triregs, each charged through an nmos from a reg (c = 1),
// then isolated (c = 0, capacitive state), then joined by a tranif1 (e = 1).
// Table 7-7 levels: large 4, medium 2, small 1.
//   A: la (large) holds 0, sa (small) holds 1 -> joined: 0 0
//   B: db (default = medium) holds 1, sb (small) holds 0 -> 1 1
//      (1 1 only if the default is medium or large, not small)
//   C: dc (default) holds 1, mc (medium) holds 0 -> x x
//      (equal sizes only if the default is exactly medium)
//   D: ld (large) holds 1, dd (default) holds 0 -> 1 1
//      (the default is smaller than large)
// Before joining, each trireg holds its own charge: "01 10 10 10".
// Lines: "01 10 10 10", "00 11 xx 11".
//! inherited IEEE 1364-2005 7.13.2
// native-required
`timescale 1ns/1ns
module b_7_13_2_charge_strength_sharing;
  reg c, e;
  reg va, vsa, vb, vsb, vc, vmc, vd, vdd;
  trireg (large) la;  trireg (small) sa;
  trireg db;          trireg (small) sb;
  trireg dc;          trireg (medium) mc;
  trireg (large) ld;  trireg dd;
  nmos na1(la, va, c), na2(sa, vsa, c), nb1(db, vb, c), nb2(sb, vsb, c);
  nmos nc1(dc, vc, c), nc2(mc, vmc, c), nd1(ld, vd, c), nd2(dd, vdd, c);
  tranif1 ta(la, sa, e), tb(db, sb, e), tc(dc, mc, e), td(ld, dd, e);
  initial begin
    e = 0; c = 1;
    va = 0; vsa = 1; vb = 1; vsb = 0; vc = 1; vmc = 0; vd = 1; vdd = 0;
    #1 c = 0;
    #1 $display("%b%b %b%b %b%b %b%b", la, sa, db, sb, dc, mc, ld, dd);
    e = 1;
    #1 $display("%b%b %b%b %b%b %b%b", la, sa, db, sb, dc, mc, ld, dd);
    $finish(0);
  end
endmodule
