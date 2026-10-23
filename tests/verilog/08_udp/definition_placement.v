// IEEE 1364-2005 §8.1, p. 105: "UDP definitions are independent of modules;
// they are at the same level as module definitions in the syntax hierarchy.
// They can appear anywhere in the source text, either before or after they
// are instantiated inside a module. They shall not appear between the
// keywords module and endmodule."
//
// inv_before is defined before the module that instantiates it, inv_after
// after it; both are the same inverter table (0 : 1, 1 : 0).
//   t=0 a = 0 -> both outputs 1; displayed at t=1: "1 1"
//   t=1 a = 1 -> both outputs 0; displayed at t=2: "0 0"
// The UDP outputs have no delay, so one time unit after each change both
// have settled.
//! inherited IEEE 1364-2005 8.1
`timescale 1ns/1ns
primitive inv_before(q, a);
  output q;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive

module b_8_1_definition_placement;
  reg a;
  wire y1, y2;
  inv_before u1(y1, a);
  inv_after u2(y2, a);
  initial begin
    a = 0;
    #1 $display("%b %b", y1, y2);
    a = 1;
    #1 $display("%b %b", y1, y2);
    $finish(0);
  end
endmodule

primitive inv_after(q, a);
  output q;
  input a;
  table
    0 : 1;
    1 : 0;
  endtable
endprimitive
