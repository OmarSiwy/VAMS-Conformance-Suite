// IEEE 1364-2005 §4.11, p. 39-40: "The text macro names are defined in the
// linear order of appearance in the set of input files that make up the
// description of the design unit. Subsequent definitions of the same name
// override the previous definitions for the balance of the input files."
// "The local name spaces are block, module, generate block, port, specify
// block, and attribute. Once a name is defined within the block, module,
// port, generate block, or specify block name space, it shall not be defined
// again in that space". "The block name space is introduced by the named
// block (see 9.8), function (see 10.4), and task (see 10.2) constructs."
// "A port name introduced in the port name space may be reintroduced
// in the module name space by declaring a variable or a wire with the same
// name as the port name."
//
// x is declared once in each of three spaces: top's module space (reg [3:0]
// x = 1), the named block blk (integer x = 2) and leaf's module space
// (reg [3:0] x = 4). Each reference resolves in its own space: 1, blk's x
// 2, u.x 4. The generate block space is pinned apart
// (generate_block_name_space.v). leaf's port a is
// reintroduced by `wire a;` and y by `reg y;`: y = ~a = ~1'b0 = 1.
// `V is defined as 5, used, redefined as 6, used: 5 then 6. a changes at
// t=1, not t=0: §9.9, p. 143, "There shall be no implied order of execution
// between initial and always constructs", so leaf's always must reach @(a)
// first.
// Output (t=2, then t=3): "1 2 1 5 6" then "u.x=4".
//! inherited IEEE 1364-2005 4.11
`timescale 1ns/1ns
module b_4_11_leaf (a, y);
  input a;
  output y;
  wire a;
  reg y;
  reg [3:0] x;
  initial begin
    x = 4;
    #3 $display("u.x=%0d", x);
  end
  always @(a) y = ~a;
endmodule
module b_4_11_name_spaces;
  reg [3:0] x;
  reg a;
  wire y;
  integer v1, v2;
  b_4_11_leaf u (a, y);
`define V 5
  initial v1 = `V;
`define V 6
  initial v2 = `V;
  initial begin : blk
    integer x;
    x = 2;
    b_4_11_name_spaces.x = 1;
    #1 a = 1'b0;
    #1 $display("%0d %0d %b %0d %0d", b_4_11_name_spaces.x, x, y, v1, v2);
    #2 $finish(0);
  end
endmodule
