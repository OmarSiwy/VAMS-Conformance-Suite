// IEEE 1364-2005 §4.8.2, p. 34: "Implicit conversion shall take place when an
// expression is assigned to a real. Individual bits that are x or z in the
// net or the variable shall be treated as zero upon conversion."
//
// Into real r (printed %f), from reg [3:0] v:
//   v = 4'b1x01: the x bit counts as 0 -> 1001 = 9.000000
//   v = 4'bz1z1: each z counts as 0 -> 0101 = 5.000000
// and from a net, wire [3:0] n = {2'bz1, 2'b1x}: -> 0110 = 6.000000
//! inherited IEEE 1364-2005 4.8.2
module b_4_8_2_unknown_bits_to_real;
  real r;
  reg [3:0] v;
  wire [3:0] n = {2'bz1, 2'b1x};
  initial begin
    v = 4'b1x01; r = v; $write("%f ", r);
    v = 4'bz1z1; r = v; $write("%f ", r);
    #1 r = n; $display("%f", r);
    $finish(0);
  end
endmodule
