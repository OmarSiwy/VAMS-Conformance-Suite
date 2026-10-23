// IEEE 1364-2005 §3.5, p. 9: "Constant numbers can be specified as integer
// constants (defined in 3.5.1) or real constants." Syntax 3-1 gives number
// ::= decimal_number | octal_number | binary_number | hex_number |
// real_number, with the bases '[s|S]d|D, '[s|S]b|B, '[s|S]o|O, '[s|S]h|H.
//
// One constant for each production, and the §3.5.1 examples (pp. 11-12):
//   659 (unsigned_number) -> 659; 'h 837FF -> 837ff hex = 538623;
//   'o7460 -> 7*512 + 4*64 + 6*8 + 0 = 3888
//   4'b1001 -> 1001; 5 'D 3 -> 00011; 3'b01x -> 01x
//   12'hx -> xxx; 16'hz -> zzzz; 16'sd? (the same as 16'sbz) -> zzzz
//   -8 'd 6 = -(8'd6) in 8 bits -> 11111010
//   4 'shf -> 1111, signed so %0d prints -1
//   -4 'sd15 = -(-4'd1) -> 0001
//   6'O77 (octal, upper-case base) -> 63; 4'B1z0X -> 1z0x
//   8'hAb === 8'hab (hex digits are case insensitive) -> 1
//   27_195_000 -> 27195000; 16'b0011_0101_0001_1111 -> 351f;
//   32 'h 12ab_f001 -> 12abf001
//   real_number: 1.5e+2 = 150 -> 150.000000; 2.5E-1 -> 0.250000
//! inherited IEEE 1364-2005 3.5
module b_3_5_number_forms;
  initial begin
    $display("%0d %0d %0d", 659, 'h 837FF, 'o7460);
    $display("%b %b %b", 4'b1001, 5 'D 3, 3'b01x);
    $display("%h %h %h", 12'hx, 16'hz, 16'sd?);
    $display("%b %0d %b", -8 'd 6, 4 'shf, -4 'sd15);
    $display("%0d %b %b", 6'O77, 4'B1z0X, 8'hAb === 8'hab);
    $display("%0d %h %h", 27_195_000, 16'b0011_0101_0001_1111, 32 'h 12ab_f001);
    $display("%f %f", 1.5e+2, 2.5E-1);
    $finish(0);
  end
endmodule
