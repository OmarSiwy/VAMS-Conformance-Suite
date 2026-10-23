// IEEE 1364-2005 §9.3.2, p. 124: "The left-hand side of the assignment can
// be ... a constant bit-select of a vector net, a part-select of a vector
// net"; each force holds its bits "until a release procedural statement is
// executed on the net". Nothing bounds how many selects of one net are
// forced. A native executable kept four per net until 2026-10 (#29; a fifth
// fell back to the interpreter); it now keeps one row per distinct select.
//
// w is 8 bits and u 4 bits, both driven by every bit of d. w has six forced
// selects (w[0] to w[4] and w[6:5] = 2'b10), u two (u[0], u[3:2] = 2'b01).
//   d = 0: w = 0 10 11111 = 01011111 (bit 7 the driver's 0);
//          u = 01 0 1     = 0101     (bit 1 the driver's 0)
//   d = 1: w's bit 7 and u's bit 1 follow the driver: 11011111 0111
//   release w[4], w[0] and u[3:2] with d = 1: the drivers give the same 1s
//          to w, and u[3:2] becomes 11: 11011111 1111
//   d = 0: w = 0 10 0 111 0 = 01001110; u = 00 0 1 = 0001
//! inherited IEEE 1364-2005 9.3.2
// native-required
`timescale 1ns/1ns
module native_force_many_selects_of_one_net;
  reg d;
  wire [7:0] w;
  wire [3:0] u;
  assign w = {8{d}};
  assign u = {4{d}};
  initial begin
    d = 1'b0;
    #1 force w[0] = 1'b1;
    force w[1] = 1'b1;
    force w[2] = 1'b1;
    force w[3] = 1'b1;
    force w[4] = 1'b1;
    force w[6:5] = 2'b10;
    force u[0] = 1'b1;
    force u[3:2] = 2'b01;
    #1 $display("%b %b", w, u);
    d = 1'b1;
    #1 $display("%b %b", w, u);
    release w[4];
    release w[0];
    release u[3:2];
    #1 $display("%b %b", w, u);
    d = 1'b0;
    #1 $display("%b %b", w, u);
    $finish(0);
  end
endmodule
