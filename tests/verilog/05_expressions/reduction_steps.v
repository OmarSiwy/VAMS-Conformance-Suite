// IEEE 1364-2005 §5.1.11, p. 51: "For reduction and, reduction or, and
// reduction xor operators, the first step of the operation shall apply the
// operator between the first bit of the operand and the second using logic
// Table 5-17 through Table 5-19. The second and subsequent steps shall apply
// the operator between the 1-bit result of the prior step and the next bit of
// the operand using the same logic table. For reduction nand, reduction nor,
// and reduction xnor operators, the result shall be computed by inverting the
// result of the reduction and, reduction or, and reduction xor operation,
// respectively."
//
// Table 5-20 (p. 52), columns & ~& | ~| ^ ~^:
//   4'b0000 -> 0 1 0 1 0 1       4'b1111 -> 1 0 1 0 0 1
//   4'b0110 -> 0 1 1 0 0 1       4'b1000 -> 0 1 1 0 1 0
// Stepping unknowns through Tables 5-17..5-19 (bit 3 first):
//   &4'b1x11: 1&x = x, x&1 = x, x&1 = x -> x;   ~& -> x
//   &4'b1x01: 1&x = x, x&0 = 0, 0&1 = 0 -> 0;   ~& -> 1
//   |4'b0z00: 0|z = x, x|0 = x, x|0 = x -> x;   ~| -> x
//   |4'b0z10: 0|z = x, x|1 = 1, 1|0 = 1 -> 1;   ~| -> 0
//   ^4'b10z0: 1^0 = 1, 1^z = x, x^0 = x -> x;   ~^ -> x
//! inherited IEEE 1364-2005 5.1.11
module b_5_1_11_reduction_steps;
  reg [3:0] v [0:3];
  integer n;
  initial begin
    v[0] = 4'b0000;
    v[1] = 4'b1111;
    v[2] = 4'b0110;
    v[3] = 4'b1000;
    for (n = 0; n < 4; n = n + 1)
      $display("%b: %b %b %b %b %b %b", v[n], &v[n], ~&v[n], |v[n], ~|v[n], ^v[n], ~^v[n]);
    $display("and=%b%b %b%b", &4'b1x11, ~&4'b1x11, &4'b1x01, ~&4'b1x01);
    $display("or=%b%b %b%b", |4'b0z00, ~|4'b0z00, |4'b0z10, ~|4'b0z10);
    $display("xor=%b%b", ^4'b10z0, ~^4'b10z0);
    $finish(0);
  end
endmodule
