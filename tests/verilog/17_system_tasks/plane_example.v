// IEEE 1364-2005 §17.5.4, Example 2, pp. 306-307: "An example of the usage of
// the plane format tasks follows. The logical function of this PLA is shown
// first, followed by the PLA personality in the new format, the Verilog HDL
// description using the $async$and$plane system task, and finally the result
// of running the simulation." The plane format: "0 Take the complemented
// input value. 1 Take the true input value. ... z Do-not-care; the input
// value is of no significance. ? Same as z."
//
// The clause's module, renamed, with `timescale added (its delays have
// none). Function: b[1] = a[1] & ~a[2]; b[2] = a[3]; b[3] = ~a[1] & ~a[3];
// b[4] = 1 (a row of ?s selects nothing, so the AND is empty, 1).
//   a = 111: b1 = 1&0 = 0, b2 = 1, b3 = 0&0 = 0, b4 = 1  -> 0101
//   a = 000: b1 = 0&1 = 0, b2 = 0, b3 = 1&1 = 1, b4 = 1  -> 0011
//   a = xxx: b1 = x&x = x, b2 = x, b3 = x&x = x, b4 = 1  -> xxx1
//   a = 101: b1 = 1&1 = 1, b2 = 1, b3 = 0&0 = 0, b4 = 1  -> 1101
// which is the clause's printed output. Each display follows its stimulus
// by 10 units, so the asynchronous array has settled.
//! inherited IEEE 1364-2005 17.5.4
`timescale 1 ns / 1 ns
module b_17_5_4_plane_example;
`define rows 4
`define cols 3
  reg [1:`cols] a, mem[1:`rows];
  reg [1:`rows] b;
  initial begin
    // PLA system call
    $async$and$plane(mem,a[1:3],b[1:4]);
    mem[1] = 3'b10?;
    mem[2] = 3'b??1;
    mem[3] = 3'b0?0;
    mem[4] = 3'b???;
    // stimulus and display
    #10 a = 3'b111;
    #10 $displayb(a, " -> ", b);
    #10 a = 3'b000;
    #10 $displayb(a, " -> ", b);
    #10 a = 3'bxxx;
    #10 $displayb(a, " -> ", b);
    #10 a = 3'b101;
    #10 $displayb(a, " -> ", b);
  end
endmodule
