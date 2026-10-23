// IEEE 1364-2005 §4.9.3, p. 35: "Each reg in the array is known as an element
// or word and is addressed by a single array index." "To assign a value to a
// memory word, an index shall be specified. The index can be an expression.
// ... For example, a program counter reg could be used to index into a RAM."
// §4.9.3.1.1, p. 35, the clause's declarations (its `time chng_hist[1:1000]`
// has no `;`, added here): mema[0:255] of 8-bit regs, arrayb[7:0][0:255] of
// one-bit regs, w_array[7:0][5:0] of wires, inta[1:64] of integers,
// chng_hist[1:1000] of times, and t_index. §4.9.3.1.2, p. 35, its legal
// assignments: "mema[1] = 0; // Assigns 0 to the second element of mema",
// "arrayb[1][0] = 0;", "inta[4] = 33559;", "chng_hist[t_index] = $time;".
//
// At t=3, with pc = 5 and t_index = 7:
//   mema[1] = 0 -> 00; mema[pc + 1] = 8'hA5 writes mema[6] -> a5, and
//   mema[2], never written, stays xx (a reg starts at x, §4.2.2);
//   arrayb[1][0] = 0, arrayb[1][1] = 1 -> 01; inta[4] = 33559;
//   chng_hist[7] = $time = 3.
// Output: "00 a5 xx 01 33559 3".
//! inherited IEEE 1364-2005 4.9.3 4.9.3.1.1 4.9.3.1.2
`timescale 1ns/1ns
module b_4_9_3_1_1_array_declarations;
  reg [7:0] mema[0:255];
  reg arrayb[7:0][0:255];
  wire w_array[7:0][5:0];
  integer inta[1:64];
  time chng_hist[1:1000];
  integer t_index;
  reg [7:0] pc;
  initial begin
    #3;
    pc = 5;
    t_index = 7;
    mema[1] = 0;
    mema[pc + 1] = 8'hA5;
    arrayb[1][0] = 0;
    arrayb[1][1] = 1;
    inta[4] = 33559;
    chng_hist[t_index] = $time;
    $display("%h %h %h %b%b %0d %0d", mema[1], mema[6], mema[2], arrayb[1][0], arrayb[1][1], inta[4], chng_hist[7]);
    $finish(0);
  end
endmodule
