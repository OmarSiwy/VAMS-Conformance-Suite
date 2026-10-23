// The other two halves of the inherited §17.2.9 row (Table 9-2, "$readmemb,
// $readmemh — Supported in digital context: Yes"): the four-argument form that
// names an explicit address range, and four-state data.
//
// The inherited rules pinned here:
//   $readmemb(filename, memory, start_addr, finish_addr) loads beginning at
//   start_addr and proceeding TOWARD finish_addr. When start_addr is GREATER
//   than finish_addr the load runs DOWNWARD. Addresses outside [finish_addr,
//   start_addr] are not touched. For $readmemb each data word is a binary
//   number whose digits may include x and z, and an unknown digit loads an
//   unknown bit.
//
// HAND DERIVATION with `reg [3:0] m [0:7]` and 09_readmemb_range.bin:
//
//     0001
//     0010
//     x1z0
//     1111
//
//   the call is $readmemb("09_readmemb_range.bin", m, 5, 2), so start 5 >
//   finish 2 and the four words go to descending addresses 5, 4, 3, 2:
//     m[5] <- 4'b0001
//     m[4] <- 4'b0010
//     m[3] <- 4'bx1z0
//     m[2] <- 4'b1111
//   m[1] and m[6] are outside the range and were never assigned, so they hold
//   the initial X of every variable in this runner and read back as "xxxx".
//
//   Printed in ASCENDING address order m[1]..m[6] — deliberately the opposite
//   of the load order, so the file cannot pass by coincidence of direction:
//       xxxx 1111 x1z0 0010 0001 xxxx
//
// The four data words are all different from each other and the descending
// load makes the printed sequence the REVERSE of the file's, which is the
// single assertion this fixture exists for: a loader that ignores the
// start > finish direction prints "xxxx 0001 0010 x1z0 1111 xxxx", i.e. the
// same six fields in the other order, and nothing else about the file changes.
//
// `x1z0` carries three distinct states in one word and its unknown digits are
// NOT adjacent, so a loader that widens or right-justifies incorrectly moves
// the `1` or the `z` and is visible; %b prints one character per declared bit
// so the placement is exact.
//
//! lrm 9.5 (Table 9-2)
//! inherited IEEE 1364-2005 17.2.9 ($readmemb range form, descending load, x/z data)
//! data 09_readmemb_range.bin
//! expect stdout 09_readmemb_range.expected.txt
`timescale 1ns/1ns
module d09_readmemb_range;
  reg [3:0] m [0:7];
  initial begin
    $readmemb("09_readmemb_range.bin", m, 5, 2);
    $display("%b %b %b %b %b %b", m[1], m[2], m[3], m[4], m[5], m[6]);
    $finish(0);
  end
endmodule
