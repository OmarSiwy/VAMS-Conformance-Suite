// The design specify_objects.c walks (VAMS-2023 11.6.15): a cell with
// a specify block — three module paths and two timing checks — instantiated
// once. The block is IEEE 1364 Clause 14/15 text, inherited through §1.1;
// VerA parses it in full and applies none of it (W0251), and the VPI's
// §11.6.15 objects are the model of what it declares.
//
//   (a => y) = (2, 3);                 parallel, rise 2 fall 3
//   if (b) (b *> y) = 4;               full, state-dependent, one delay 4
//   (posedge clk => (q : d)) = (1, 2, 3, 4, 5, 6);
//                                      parallel, edge-sensitive, six delays
//   $setup(d, posedge clk, 5, notif);  one limit 5, notifier notif
//   $width(posedge clk, 10);           one limit 10, no data event
`timescale 1ns/1ns

module p06_cell(a, b, clk, d, y, q);
  input a, b, clk, d;
  output y, q;
  reg q, notif;
  and (y, a, b);
  always @(posedge clk) q = d;
  specify
    (a => y) = (2, 3);
    if (b) (b *> y) = 4;
    (posedge clk => (q : d)) = (1, 2, 3, 4, 5, 6);
    $setup(d, posedge clk, 5, notif);
    $width(posedge clk, 10);
  endspecify
endmodule

module p06_top;
  reg a, b, clk, d;
  wire y, q;
  p06_cell u (a, b, clk, d, y, q);
  initial begin
    a = 0; b = 0; clk = 0; d = 0;
    #5 $finish(0);
  end
endmodule
