// The digital design primitives.c walks: LRM 11.6.13's primitives
// (two gates and a UDP instance) and 11.6.14's UDP definition. No
// directives: every number about it is asserted from C.
//
//   and  #(2,3) (y, a, b);        a gate: output y, inputs a and b, delays
//                                 rise 2 and fall 3 (1 ns each, below)
//   not          (ny, y);         a gate with no delay: output ny, input y
//   p04_latch    lat (q, d, en);  a UDP instance of the sequential p04_latch
//
// p04_latch is a level-sensitive latch, IEEE 1364 §8.3's shape: output q,
// inputs d and en, `initial q = 0`, three table entries of 2 inputs, the
// current state and the output — 4 symbol entries each.
//
// THE TIMELINE: a = 1, b = 1, d = 1, en = 1 at t=0; y rises at t=2 (the
// rise delay), ny falls then; q follows d at once. $finish(0) at t=10.

`timescale 1ns/1ns

primitive p04_latch (q, d, en);
  output q;
  reg q;
  input d, en;
  initial q = 0;
  table
  // d en : q : q+
     1  1 : ? : 1;
     0  1 : ? : 0;
     ?  0 : ? : -;
  endtable
endprimitive

module p04_prims;
  reg  a, b, d, en;
  wire y, ny, q;

  and #(2,3) (y, a, b);
  not (ny, y);
  p04_latch lat (q, d, en);

  initial begin
    a = 1; b = 1; d = 1; en = 1;
    #10 $finish(0);
  end
endmodule
