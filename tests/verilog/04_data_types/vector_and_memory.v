// IEEE 1364-2005 §4.9.3.1.3, p. 35: "A memory of n 1-bit regs is different
// from an n-bit vector reg.
//     reg [1:n] rega; // An n-bit register is not the same
//     reg mema [1:n]; // as a memory of n 1-bit registers"
//
// With n = 4: rega takes 4'b1010 in one assignment (its msb is rega[1], so
// rega[1] = 1, rega[4] = 0); mema takes the same bits one word at a time.
// Output: "rega=1010 r1=1 r4=0 mema=1010".
//! inherited IEEE 1364-2005 4.9.3.1.3
module b_4_9_3_1_3_vector_and_memory;
  reg [1:4] rega;
  reg mema [1:4];
  initial begin
    rega = 4'b1010;
    mema[1] = 1'b1;
    mema[2] = 1'b0;
    mema[3] = 1'b1;
    mema[4] = 1'b0;
    $display("rega=%b r1=%b r4=%b mema=%b%b%b%b", rega, rega[1], rega[4], mema[1], mema[2], mema[3], mema[4]);
    $finish(0);
  end
endmodule
