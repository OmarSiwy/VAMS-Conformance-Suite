// IEEE 1364-2005 §5.4.3, p. 64, "Example of self-determined expressions":
//   $display("a*b=%h", a*b);// expression size is self-determined
//   c = {a**b};             // expression a**b is self-determined
//                           // due to concatenation operator {}
//   c = a**b;               // expression size is determined by c
//
// reg [3:0] a = 4'hF, reg [5:0] b = 6'hA, reg [15:0] c:
//   a*b: self-determined, max(4,6) = 6 bits: 15*10 = 150 = 'h96, mod 64 =
//     22 = 'h16 -> "16" (the clause: "'h96 was truncated to 'h16")
//   c = {a**b}: a**b is L(a) = 4 bits: 15 == -1 (mod 16), (-1)**10 = 1 -> 1
//   c = a**b: 16 bits: 15**2 = 225, 15**4 = 50625, 15**5 = 759375 == 38479
//     (mod 65536), 15**10 == 38479**2 = 1480633441 == 44129 = 'hac61
// The clause lists "a*b=16", "a**b=1", "c=ac61", but prints with %h, which
// §17.1.1.3 (p. 282) pads to the full width ("In other radices, leading
// zeros are always displayed"): a*b is 6 bits -> 2 digits "16", c is 16 bits
// -> 4 digits, "0001" and "ac61". The values are the clause's; the padding
// is §17.1.1.3's.
//! inherited IEEE 1364-2005 5.4.3
module b_5_4_3_self_determined_example;
  reg [3:0] a;
  reg [5:0] b;
  reg [15:0] c;
  initial begin
    a = 4'hF;
    b = 6'hA;
    $display("a*b=%h", a*b);
    c = {a**b};
    $display("a**b=%h", c);
    c = a**b;
    $display("c=%h", c);
    $finish(0);
  end
endmodule
