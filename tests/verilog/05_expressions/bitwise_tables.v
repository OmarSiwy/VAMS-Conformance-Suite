// IEEE 1364-2005 §5.1.10, pp. 50-51: "The bitwise operators shall perform
// bitwise manipulations on the operands; that is, the operator shall combine
// a bit in one operand with its corresponding bit in the other operand to
// calculate 1 bit for the result. Logic Table 5-12 through Table 5-16 show the
// results for each possible calculation." ... "When the operands are of
// unequal bit length, the shorter operand is zero-filled in the most
// significant bit positions."
//
// Every cell of Tables 5-12..5-15 at once: i and j are 16-bit vectors whose
// bit pairs, MSB first, walk the rows (i) and columns (j) 0,1,x,z:
//   i = 0000 1111 xxxx zzzz     j = 01xz 01xz 01xz 01xz
// Reading each table's rows left to right:
//   & (5-12):  0000 01xx 0xxx 0xxx
//   | (5-13):  01xx 1111 x1xx x1xx
//   ^ (5-14):  01xx 10xx xxxx xxxx
//   ^~ / ~^ (5-15): 10xx 01xx xxxx xxxx
//   ~ (5-16) of k = 01xz: 10xx
// Zero fill: 4'b1111 & 8'b1010_1010: 4'b1111 -> 0000_1111 -> 0000_1010;
//            4'b1111 | 8'b1010_1010 -> 1010_1111.
//! inherited IEEE 1364-2005 5.1.10
module b_5_1_10_bitwise_tables;
  reg [15:0] i, j;
  reg [3:0] k;
  initial begin
    i = 16'b0000_1111_xxxx_zzzz;
    j = 16'b01xz_01xz_01xz_01xz;
    k = 4'b01xz;
    $display("and=%b", i & j);
    $display("or=%b", i | j);
    $display("xor=%b", i ^ j);
    $display("xnor=%b %b", i ^~ j, i ~^ j);
    $display("not=%b", ~k);
    $display("fill=%b %b", 4'b1111 & 8'b1010_1010, 4'b1111 | 8'b1010_1010);
    $finish(0);
  end
endmodule
