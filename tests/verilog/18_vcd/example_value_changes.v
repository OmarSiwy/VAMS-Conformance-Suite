// IEEE 1364-2005 §18.2.4, p. 337: "The following example illustrates the
// format of the four-state VCD file." §18.1.3, p. 327: "When the $dumpoff task
// is executed, a checkpoint is made in which every selected variable is dumped
// as an x value. When the $dumpon task is later executed, each variable is
// dumped with its value at that time. In the interval between $dumpoff and
// $dumpon, no value changes are dumped." §18.1.4, p. 328: "The $dumpall task
// creates a checkpoint in the VCD file that shows the current value of all
// selected variables." ... "Values of variables that do not change during a
// time increment are not dumped." §18.2.3.9, p. 335: "The $dumpall keyword
// specifies current values of all variables dumped." §18.2.3.10, p. 336: "The
// $dumpoff keyword indicates all variables dumped with X values."
// §18.2.3.11: "The $dumpon keyword indicates resumption of dumping and lists
// current values of all variables dumped." §18.2.3.12: "The section beginning
// with $dumpvars keyword lists initial values of all variables dumped."
//
// This design replays the value-change half of the §18.2.4 example, section
// for section. Two substitutions, both in the declarations: the example's
// trireg nets net1..net3 are regs here (a trireg cannot show the z the
// example gives net1 at #2000), and its task t1's accumulator and index live
// in a module instance named t1 (task scopes are pinned by
// task_function_scopes.v). So `$var trireg` reads `$var reg` and
// `$scope task t1` reads `$scope module t1`; every value line is the
// example's. Writer choices §18.2 leaves open that the golden pins: the range
// is its own token, `accumulator [31:0]` (the example glues it,
// `accumulator[31:0]`; both are free format), and no time record is written
// for #1500, where values change while dumping is off (an empty `#1500` would
// be legal Syntax 18-8 but fails the token comparison).
//
// HAND DERIVATION (codes from `!` in $var order, the d09_11 CONVENTION:
// net1 !, net2 ", net3 #, accumulator $, index %; the example's *@ *# *$ (k {2):
//   #500 $dumpvars: nothing is assigned yet, every reg and the integer is x:
//        x! x" x# bx $ bx %  (a vector of all x shortens to one x, Table 18-1)
//   #505 net1 0, net2 1, net3 1; accumulator = 14'b10zx1110x11100 zero-
//        extended to 32 bits, whose leading zeros extend a 1 and so drop
//        (Table 18-1): b10zx1110x11100; index likewise b1111000101z01x.
//   #510 0#   #520 1#   #530 0# and accumulator all z -> bz $
//   #535 $dumpall: every variable, changed or not: 0! 1" 0# bz $
//        b1111000101z01x %
//   #540 1#
//   #1000 $dumpoff: every variable as x: x! x" x# bx $ bx %
//   #1500 net1 z, net3 0, accumulator 0, index x: dumping is off, nothing.
//   #2000 $dumpon: the values at that time: z! 1" 0# b0 $ bx %
//   #2010 1#
//! inherited IEEE 1364-2005 18.2.4 18.1.3 18.1.4 18.2.3.9 18.2.3.10 18.2.3.11 18.2.3.12
//! expect vcd example_value_changes.vcd == example_value_changes.expected.vcd
`timescale 1ns/1ns
module b_18_2_4_m1;
  reg net1, net2, net3;
endmodule

module b_18_2_4_t1;
  reg [31:0] accumulator;
  integer index;
endmodule

module top;
  b_18_2_4_m1 m1();
  b_18_2_4_t1 t1();
  initial begin
    $dumpfile("example_value_changes.vcd");
    #500 $dumpvars(0, top);
    #5 m1.net1 = 1'b0;
       m1.net2 = 1'b1;
       m1.net3 = 1'b1;
       t1.accumulator = 14'b10zx1110x11100;
       t1.index = 14'b1111000101z01x;
    #5 m1.net3 = 1'b0;
    #10 m1.net3 = 1'b1;
    #10 m1.net3 = 1'b0;
        t1.accumulator = 32'bz;
    #5 $dumpall;
    #5 m1.net3 = 1'b1;
    #460 $dumpoff;
    #500 m1.net1 = 1'bz;
         m1.net3 = 1'b0;
         t1.accumulator = 0;
         t1.index = 32'bx;
    #500 $dumpon;
    #10 m1.net3 = 1'b1;
    $finish(0);
  end
endmodule
