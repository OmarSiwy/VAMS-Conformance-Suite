// IEEE 1364-2005 §17.5.2, p. 304: "The logic arrays are modeled with and, or,
// nand, and nor logic planes. This applies to all array types and formats."
// §17.5.4, pp. 304-305: "The array system call allows for a 1 or 0 in the
// memory that has been declared. A 1 means take the input value, and a 0
// means do not take the input value." For the plane call: "0 Take the
// complemented input value. 1 Take the true input value. ... z Do-not-care;
// the input value is of no significance. ? Same as z."
//
// The clause names the four planes but shows the function of only the and
// plane (§17.5.4 Example 1: mem 1100000 under $async$and$array gives
// b1 = a1 & a2). The or, nand and nor planes are read the same way, with
// their own gate: each output term is its row's selected input values
// combined by or, by and then inverted, or by or then inverted. No row here
// selects nothing, so the empty-plane value is not asked. The synchronous
// forms evaluate at the call and "the output terms are updated without any
// delay" (§17.5.1), so each $display follows its call directly.
//
// Array format, a = 3'b101 (a[1]=1, a[2]=0, a[3]=1):
//   arr[1] = 101 takes a[1], a[3] = 1, 1;  arr[2] = 110 takes a[1], a[2] = 1, 0
//   and: 1&1=1, 1&0=0 -> 10    or: 1|1=1, 1|0=1 -> 11
//   nand: 01                   nor: 00
// Plane format, same a:
//   pln[1] = 1?0 takes a[1], ~a[3] = 1, 0;  pln[2] = ?0? takes ~a[2] = 1
//   and: 1&0=0, 1 -> 01        or: 1|0=1, 1 -> 11
//   nand: 10                   nor: 00
//! inherited IEEE 1364-2005 17.5.2
`timescale 1 ns / 1 ns
module b_17_5_2_logic_planes;
  reg [1:3] arr [1:2];
  reg [1:3] pln [1:2];
  reg [1:3] a;
  reg [1:2] b;
  initial begin
    arr[1] = 3'b101;
    arr[2] = 3'b110;
    pln[1] = 3'b1?0;
    pln[2] = 3'b?0?;
    a = 3'b101;
    $sync$and$array(arr, a, b);  $display("array and  %b", b);
    $sync$or$array(arr, a, b);   $display("array or   %b", b);
    $sync$nand$array(arr, a, b); $display("array nand %b", b);
    $sync$nor$array(arr, a, b);  $display("array nor  %b", b);
    $sync$and$plane(pln, a, b);  $display("plane and  %b", b);
    $sync$or$plane(pln, a, b);   $display("plane or   %b", b);
    $sync$nand$plane(pln, a, b); $display("plane nand %b", b);
    $sync$nor$plane(pln, a, b);  $display("plane nor  %b", b);
    $finish(0);
  end
endmodule
