// IEEE 1364-2005 §7.1.2, p. 76: "Only the instances of the gate primitives
// shown in Table 7-2 can have the drive strength specification." Table 7-2:
// and, or, xor, nand, nor, xnor, buf, bufif0, bufif1, not, notif0, notif1,
// pulldown, pullup. Syntax 7-1 gives mos_switchtype only [delay3].
//
// nmos is a MOS switch, not in Table 7-2, so (strong1, strong0) on it is
// illegal. Legal neighbour: a drive strength on nand in
// instance_list_shared_spec.v.
//! inherited IEEE 1364-2005 7.1.2
//! reject E0208
//! reject expected an identifier: found strong1
//! neighbour instance_list_shared_spec.v
module b_7_1_2_mos_drive_strength_rejected;
  reg d, g;
  wire o;
  nmos (strong1, strong0) m1(o, d, g);
  initial $finish(0);
endmodule
