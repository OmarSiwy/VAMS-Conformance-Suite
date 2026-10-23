// IEEE 1364-2005 §18.1.2: "the first argument indicates how many levels of
// the hierarchy below each specified module instance to dump ... Subsequent
// arguments specify which scopes of the model to dump ... These arguments can
// specify entire modules or individual variables within a module", and
// Example 1: "$dumpvars (1, top); ... dumps all variables within the module
// top; it does not dump variables in any of the modules instantiated by
// module top". "The argument 0 applies only to subsequent arguments that
// specify module instances, and not to individual variables."
//
// §18.2.3.7 `$var var_type size identifier_code reference $end`, with
// var_type `wire`, `reg` or `integer` as declared and the reference carrying
// `[msb:lsb]` for a vector. §18.2.2 Table 18-1: a vector value is written
// with the leading digits that left-extension would supply removed.
//
// HAND DERIVATION of vcd_dumpvars_levels.expected.vcd,
// with the same convention as d09_11: codes from `!` in $var order, and a
// module's variables listed ports, then nets, then variables.
//
//   Selection. Level 1 on the root dumps the root's own o, s and n and
//   nothing of u — except u.q, which is named individually. u's ports i and
//   o are therefore absent (o IS the root's o: the port collapsed onto it).
//     o -> `!` wire 1, s -> `"` reg 2 [1:0], n -> `#` integer 32, q -> `$` reg 1
//
//   t=0 end of step (§18.1.3): s = 01, so i = 01 and o = ^01 = 1; n = 5;
//       q = 0.  -> 1!, b1 " (01 minus its leading 0), b101 #, 0$
//   t=2  s = 11: o = ^11 = 0, s = b11; n = -1, 32 ones (a leading 1 is not
//        redundant, so nothing is removed).
//   t=3  q = 1, alone.
//   t=4  $finish(0): nothing changed, so no #4.
//
//! inherited IEEE 1364-2005 18.1.2 ($dumpvars levels and variables)
//! inherited IEEE 1364-2005 18.2.2 (vector shortening)
//! expect vcd d09_vcd_scope.vcd == vcd_dumpvars_levels.expected.vcd
`timescale 1ns/1ns
module leaf(input [1:0] i, output o);
  reg q;
  assign o = ^i;
  initial begin
    q = 1'b0;
    #3 q = 1'b1;
  end
endmodule
module d09_vcd_scope;
  reg [1:0] s;
  integer n;
  wire o;
  leaf u(.i(s), .o(o));
  initial begin
    $dumpfile("d09_vcd_scope.vcd");
    $dumpvars(1, d09_vcd_scope, d09_vcd_scope.u.q);
    s = 2'b01;
    n = 5;
    #2 s = 2'b11;
       n = -1;
    #2 $finish(0);
  end
endmodule
