// IEEE 1364-2005 §4.6, p. 26: "There are several distinct types of nets, as
// shown in Table 4-1." Table 4-1: wire, tri, tri0, supply0, wand, triand,
// tri1, supply1, wor, trior, trireg, uwire.
// §4.2.1, p. 23: "The default initialization value for a net shall be the
// value z. ... The trireg net is an exception. The trireg net shall default
// to the value x". §4.6.4, p. 31: "When no driver drives a tri0 net, its
// value is 0 with strength pull. When no driver drives a tri1 net, its value
// is 1 with strength pull." §4.6.6, p. 32: "The supply0 and supply1 nets can
// be used to model the power supplies in a circuit." §7.13.3, p. 101: "The
// supply0 net type models ground connections. The supply1 net type models
// connections to power supplies."
//
// One undriven net of each of the twelve types, read at t=1:
//   wire z, tri z, wand z, triand z, wor z, trior z, uwire z (the default);
//   tri0 0, tri1 1; supply0 0, supply1 1; trireg x.
// Output: "zzzzzzz 0101 x".
//! inherited IEEE 1364-2005 4.6
`timescale 1ns/1ns
module b_4_6_net_types;
  wire w;
  tri t;
  wand wa;
  triand ta;
  wor wo;
  trior to;
  uwire uw;
  tri0 t0;
  tri1 t1;
  supply0 s0;
  supply1 s1;
  trireg tr;
  initial begin
    #1 $display("%b%b%b%b%b%b%b %b%b%b%b %b", w, t, wa, ta, wo, to, uw, t0, t1, s0, s1, tr);
    $finish(0);
  end
endmodule
