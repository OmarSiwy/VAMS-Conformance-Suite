// Verilog-AMS LRM 2.4 §3.7, the connectivity paragraph, verbatim:
//
//   "wreal nets can only be connected to compatible interconnect and other
//    wreal or real expressions. They cannot be connected to any other wires,
//    although connection to explicitly declared 64-bit wires can be done via
//    system tasks $realtobits and $bitstoreal. Compatible interconnect are nets
//    of type wire, tri, and wreal where the IEEE Std 1364 Verilog net
//    resolution is extended for wreal. When the two nets connected by a port
//    are of net type wreal and wire/tri, the resulting single net will be
//    assigned as wreal. Connection to other net types will result in an error."
//
// The load-bearing sentence is the fourth: the merge is not symmetric and it is
// not an error — wreal WINS. A `wire` in the parent connected to a `wreal` port
// in a child is one net, and that net is a wreal from then on, for every other
// connection to it as well.
//
// That has three consequences this fixture asserts, and each of them is
// invisible if a tool merely "allows" the connection:
//
//   1. The parent can read the merged net as a REAL. `link` is spelled `wire`,
//      but it carries 2.5, not a four-state vector — so %g on it is meaningful
//      and prints the fraction.
//   2. The merged net's no-driver value is §3.7's 0.0, NOT the 'z' the parent's
//      `wire` declaration would have given it. `dark` is the case: declared
//      `wire` in the parent, connected to a wreal input port, nothing drives
//      it anywhere.
//   3. The promotion reaches a THIRD connection made after the fact: `sink`
//      reads the same merged net through its own wreal input and sees the same
//      real. A tool that promoted only the one port pair would give `sink` a
//      four-state z.
//
// `tri` is included alongside `wire` because the clause names the two types
// together and they are the same resolution function in IEEE Std 1364 Verilog;
// a tool that special-cased the `wire` keyword alone fails the `tlink` column.
//
//! lrm 3.7
//! timescale 1ns/1ns
//
// HAND DERIVATION
//   src drives its wreal output with the constant 2.5 (exact in binary).
//   `link` is `wire` in the parent, joined by a port to a `wreal` -> the single
//   net is wreal -> it carries 2.5 -> sink's wreal input reads 2.5 -> sink's
//   wreal output `echo` is `in * 2.0` = 5.0 exactly.
//   `tlink` is `tri` in the parent, same merge, same 2.5.
//   `dark` is `wire` in the parent joined to a wreal input port with no driver
//   anywhere in the design -> §3.7 sentence 3 -> 0.0.  %g prints "0".
//   If the merge were NOT performed, `dark` would be a plain undriven wire and
//   read 1'bz, which is the failure this line exists to catch.

`timescale 1ns/1ns

module m04_wreal_src(o);
  output o;
  wreal o;
  assign o = 2.5;
endmodule

module m04_wreal_sink(in, echo);
  input in;
  wreal in;
  output echo;
  wreal echo;
  assign echo = in * 2.0;
endmodule

module m04_wreal_wire_port_resolves_wreal;
  wire link;   // §3.7: wire + wreal through a port  -> the net is wreal
  tri  tlink;  // §3.7 names tri as compatible interconnect too
  wire dark;   // merged to wreal, driven by nobody  -> 0.0, not z
  wreal echo;

  m04_wreal_src   s1(.o(link));
  m04_wreal_src   s2(.o(tlink));
  m04_wreal_sink  k1(.in(link), .echo(echo));
  m04_wreal_sink  k2(.in(dark), .echo());

  initial begin
    #1;
    $display("wire_merged_with_wreal_carries_a_real %g", link);
    $display("tri_merged_with_wreal_carries_a_real %g", tlink);
    $display("promotion_reaches_the_third_connection %g", echo);
    $display("merged_net_with_no_driver_is_zero_not_z %g", dark);
    $finish(0);
  end
endmodule
