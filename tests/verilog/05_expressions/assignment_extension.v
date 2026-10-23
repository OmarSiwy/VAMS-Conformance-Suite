// IEEE 1364-2005 §5.5.3, p. 66: "— Determine the size of the right-hand side
// by the standard assignment size determination rules (see 5.4). — If
// needed, extend the size of the right-hand side, performing sign extension
// if, and only if, the type of the right-hand side is signed."
//
// Into 8 bits, the LHS's own signedness never decides:
//   reg [7:0] u = 4'sb1010         RHS signed   -> 11111010
//   reg [7:0] u = 4'b1010          RHS unsigned -> 00001010
//   reg signed [7:0] s = 4'b1010   RHS unsigned -> 00001010
//   reg signed [7:0] s = 4'sb0110  RHS signed, sign bit 0 -> 00000110
//   integer i = 4'sb1111           RHS signed   -> -1 (%0d)
//   integer i = 4'b1111            RHS unsigned -> 15
//! inherited IEEE 1364-2005 5.5.3
module b_5_5_3_assignment_extension;
  reg [7:0] u;
  reg signed [7:0] s;
  integer i;
  initial begin
    u = 4'sb1010; $write("%b ", u);
    u = 4'b1010;  $write("%b ", u);
    s = 4'b1010;  $write("%b ", s);
    s = 4'sb0110; $display("%b", s);
    i = 4'sb1111; $write("%0d ", i);
    i = 4'b1111;  $display("%0d", i);
    $finish(0);
  end
endmodule
