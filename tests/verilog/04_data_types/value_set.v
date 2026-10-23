// IEEE 1364-2005 §4.1, p. 21: "The Verilog HDL value set consists of four
// basic values: 0 - represents a logic zero, or a false condition 1 -
// represents a logic one, or a true condition x - represents an unknown logic
// value z - represents a high-impedance state" ... "When the z value is
// present at the input of a gate or when it is encountered in an expression,
// the effect is usually the same as an x value. Notable exceptions are the
// metal-oxide semiconductor (MOS) primitives, which can pass the z value." ...
// "All bits of vectors can be independently set to one of the four basic
// values."
//
//   v = 4'b01xz: each bit holds its own value -> 01xz
//   and g(o, 1'b1, d), d = z: the and gate sees z as x; 1 & x -> x (§7.2
//     Table 7-3 row 1, column z)
//   ~d in an expression, d = z: -> x (§5.1.10 Table 5-16)
//   nmos n1(m, d, c), d = z, c = 1: the switch conducts and passes z -> z
//     (§7.5 Table 7-6, data z, control 1)
//! inherited IEEE 1364-2005 4.1
module b_4_1_value_set;
  reg [3:0] v;
  reg d, c;
  wire o, m;
  and g(o, 1'b1, d);
  nmos n1(m, d, c);
  initial begin
    v = 4'b01xz;
    d = 1'bz;
    c = 1;
    #1 $display("%b %b %b %b", v, o, ~d, m);
    $finish(0);
  end
endmodule
