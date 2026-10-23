// IEEE 1364-2005 §18.1.1, p. 325: "The $dumpfile task shall be used to specify
// the name of the VCD file." Syntax 18-1: `dumpfile_task ::= $dumpfile (
// filename ) ;`, and Syntax 18-2 (p. 326) makes a filename one literal_string,
// variable or expression.
//
// Two filenames is no dumpfile_task: a dump has one file, and nothing says
// which of the two it would be. Legal neighbours: one filename,
// dumpfile_variable_name.v; none, dumpfile_default_name.v.
//! inherited IEEE 1364-2005 18.1.1
//! reject E1100
//! reject $dumpfile takes at most one filename
//! neighbour dumpfile_default_name.v
//! neighbour dumpfile_variable_name.v
`timescale 1ns/1ns
module b_18_1_1_dumpfile_two_names_rejected;
  reg a;
  reg [7:0] v;
  initial begin
    $dumpfile("b_18_1_1_a.vcd", "b_18_1_1_b.vcd");
    a = 1'b0;
    v = 8'h00;
    #1 a = 1'b1;
  end
endmodule
