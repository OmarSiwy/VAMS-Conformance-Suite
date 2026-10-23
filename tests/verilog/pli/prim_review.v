// Runtime design for prim_review.c. The two forces share y, but only
// one is active at a time. The procedural assign reads a and drives r.
// The sequential UDP has five symbols per row, crossing a vecval boundary.
`timescale 1ns/1ns
primitive review_edge(q, a, b, c);
  output q;
  reg q;
  input a, b, c;
  initial q = 0;
  table
     1  0  ? : ? : 1;
     0 (01) ? : ? : -;
    (10) 0  ? : 0 : 1;
  endtable
endprimitive

primitive review_comb(q, a, b);
  output q;
  input a, b;
  table
    0 0 : 0;
    0 1 : 1;
    1 ? : x;
  endtable
endprimitive

module b26_prim_review;
  reg a, b, r;
  reg [3:0] bits;
  wire y;
  initial begin
    a = 1; b = 0; r = 0; bits = 4'b10xz;
    #1 force y = a;
    #1 force y = b;
    #1 release y;
    #1 assign r = a;
    #1 deassign r;
    #2 $finish(0);
  end
endmodule
