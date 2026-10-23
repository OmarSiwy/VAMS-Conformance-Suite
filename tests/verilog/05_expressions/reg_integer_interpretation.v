// IEEE 1364-2005 §5.1.6, p. 47: "A value assigned to a reg variable or a net
// shall be treated as an unsigned value unless the reg variable or net has
// been explicitly declared to be signed. A value assigned to an integer, real
// or realtime variable shall be treated as signed. A value assigned to a time
// variable shall be treated as unsigned." ... "Conversions between signed and
// unsigned values shall keep the same bit representation; only the
// interpretation changes."
//
// The clause's example (pp. 47-48), integer intA, reg [15:0] regA,
// reg signed [15:0] regS; each result is the one the clause states:
//   intA = -4'd12       size 32, unsigned: 2**32-12 = 32'hFFFFFFF4 -> intA -12
//   regA = intA / 3     both signed, size 32: -12/3 = -4 -> 16'hFFFC = 65532
//   regA = -4'd12       size 16, unsigned: 2**16-12 = 65524
//   intA = regA / 3     regA unsigned, so unsigned: 65524/3 = 21841.33 -> 21841
//   intA = -4'd12 / 3   size 32, unsigned: 4294967284/3 -> 1431655761
//   regA = -12 / 3      signed: -4 -> 65532
//   regS = -12 / 3      -4, and regS is signed -> -4
//   regS = -4'sd12 / 3  4'sd12 is -4 (4-bit signed), sign-extended; -(-4) = 4;
//                       4/3 = 1
// Table 5-9 rows the example does not reach, same bits in each pair:
//   time t = -1         64 bits, unsigned: 2**64-1; t/2 = 2**63-1
//                       = 9223372036854775807
//   wire signed [7:0] sn = -8'sd6 -> sn/3 = -2 (signed, truncated toward 0)
//   wire [7:0]        un = -8'sd6 -> 8'hFA = 250; un/3 = 83 (unsigned)
//! inherited IEEE 1364-2005 5.1.6
module b_5_1_6_reg_integer_interpretation;
  integer intA;
  reg [15:0] regA;
  reg signed [15:0] regS;
  time t;
  wire signed [7:0] sn = -8'sd6;
  wire [7:0] un = -8'sd6;
  initial begin
    intA = -4'd12;
    $display("intA=%0d", intA);
    regA = intA / 3;
    $display("regA=%0d", regA);
    regA = -4'd12;
    $display("regA=%0d", regA);
    intA = regA / 3;
    $display("intA=%0d", intA);
    intA = -4'd12 / 3;
    $display("intA=%0d", intA);
    regA = -12 / 3;
    $display("regA=%0d", regA);
    regS = -12 / 3;
    $display("regS=%0d", regS);
    regS = -4'sd12 / 3;
    $display("regS=%0d", regS);
    t = -1;
    $display("t/2=%0d", t / 2);
    #1 $display("sn/3=%0d un=%0d un/3=%0d", sn / 3, un, un / 3);
    $finish(0);
  end
endmodule
