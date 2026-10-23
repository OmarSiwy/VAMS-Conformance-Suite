// §9.14 Table 9-11 gives $clog2 "Supported in digital context: Yes /
// Supported in analog context: Yes". The analog half is already closed and
// already pinned — tests/fixtures/ch09_system_tasks/clog2.va asserts
// $clog2(9) = 4 and $clog2(8) = 3, including its statement that "an exact
// power of two does not round up". The DIGITAL half is not: the runner's whole
// system-task dispatch is four names (src/sim/digital.zig:138,140), and
// digital.zig's own unit tests at lines 1411/1479/1480/1511/1537 assert that
// $clog2 in a digital expression is REJECTED with "expression form". So the
// conformance plan's 17.10-17.11 row is open on the digital side, and its
// wording — "$clog2 and real math functions with DIGITAL TYPING, argument
// conversion" — is what this file tests: the same function, reached from a
// digital procedural expression, producing an integral digital value.
//
// $clog2(n) is the ceiling of the base-2 logarithm of n, i.e. the number of
// address bits needed to address n locations.
//
// HAND DERIVATION:
//   $clog2(0)    = 0      (defined to be 0; there is no logarithm to take)
//   $clog2(1)    = 0      log2(1) = 0 exactly
//   $clog2(2)    = 1      log2(2) = 1 exactly, an exact power of two does not
//                         round up
//   $clog2(3)    = 2      log2(3) = 1.58496..., ceiling 2
//   $clog2(1000) = 10     2^9 = 512 < 1000 <= 1024 = 2^10
//   $clog2(1024) = 10     exact power of two, does NOT become 11
//   $clog2(1025) = 11     1024 < 1025 <= 2048 = 2^11
//   $clog2(255)  = 8      2^7 = 128 < 255 <= 256 = 2^8
//
// 1024 and 1025 sit either side of the boundary and 1000 sits inside the same
// bracket as 1024: a "floor(log2)+1" implementation prints 11 for 1024 and an
// implementation that rounds a floating log2 prints 10 for 1025. The two
// neighbours catch both.
//
// The last two lines pin the DIGITAL TYPING the plan asks for: the result is
// an integral value that an ordinary assignment can narrow. $clog2(255) = 8
// assigned to `reg [7:0] w` gives 8'b00001000, and %b shows all eight declared
// bits — so a result delivered as a real, or as a value that does not take the
// assignment's width context, does not produce this line.
//
//! lrm 9.14 (Table 9-11)
//! inherited IEEE 1364-2005 17.11 ($clog2 in a digital expression)
//! expect stdout 10_clog2.expected.txt
`timescale 1ns/1ns
module d09_clog2;
  reg [7:0] w;
  initial begin
    $display("%0d %0d %0d %0d %0d %0d %0d",
             $clog2(0), $clog2(1), $clog2(2), $clog2(3),
             $clog2(1000), $clog2(1024), $clog2(1025));
    w = $clog2(255);
    $display("%b", w);
    $finish(0);
  end
endmodule
