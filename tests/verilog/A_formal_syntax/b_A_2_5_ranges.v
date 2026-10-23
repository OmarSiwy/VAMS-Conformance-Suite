// IEEE 1364-2005 A.2.5, p. 492:
//   dimension ::= [ dimension_constant_expression : dimension_constant_expression ]
//   range ::= [ msb_constant_expression : lsb_constant_expression ]
//
// A range with a descending and one with an ascending constant pair, one
// whose bounds are parameter expressions, and a two-dimensional array (two
// dimensions, one ascending and one descending):
//   reg [7:0] d = 8'h81        d[7] = 1, d[0] = 1, d[6:1] = 0
//   reg [0:3] u = 4'b1000      the msb is u[0]: u[0] = 1, u[3] = 0
//   reg [W-1:0] p, W = 3       3 bits: p = 3'b111 + 1 wraps to 0
//   reg [1:0] m [0:1][2:1]     m[1][2] = 2'b10, read back as 2
// Output: "d7=1 d0=1 u0=1 u3=0 p=0 m=2".
//! inherited IEEE 1364-2005 A.2.5
module b_A_2_5_ranges;
  parameter W = 3;
  reg [7:0] d;
  reg [0:3] u;
  reg [W-1:0] p;
  reg [1:0] m [0:1][2:1];
  initial begin
    d = 8'h81;
    u = 4'b1000;
    p = 3'b111;
    p = p + 1;
    m[1][2] = 2'b10;
    $display("d7=%b d0=%b u0=%b u3=%b p=%0d m=%0d", d[7], d[0], u[0], u[3], p, m[1][2]);
    $finish(0);
  end
endmodule
