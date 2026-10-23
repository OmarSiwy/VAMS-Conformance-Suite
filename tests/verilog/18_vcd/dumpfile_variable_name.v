// IEEE 1364-2005 §18.1.1, p. 325: "The $dumpfile task shall be used to
// specify the name of the VCD file." Syntax 18-2, p. 326:
//   filename ::= literal_string | variable | expression
//
// The name here is a variable: fname holds the 30 characters
// "b_18_1_1_dumpfile_variable.vcd", padded on the left with zero bytes to the
// reg's 40 (§5.2.3.2), which a file name does not carry. The dump must land in
// that file: the golden is read from it.
//
// HAND DERIVATION (the d09_11 CONVENTION: codes from `!` in $var order):
//   header: $timescale 1ns, scope b_18_1_1_dumpfile_variable_name, one
//   `$var reg 1 ! a`.
//   #0 $dumpvars: $dumpvars runs before a = 0, but dumping starts at the end
//   of the time unit (§18.1.3), so the section shows 0!.
//   #1 a = 1 -> 1!.
//! inherited IEEE 1364-2005 18.1.1
//! expect vcd b_18_1_1_dumpfile_variable.vcd == dumpfile_variable_name.expected.vcd
`timescale 1ns/1ns
module b_18_1_1_dumpfile_variable_name;
  reg a;
  reg [8*40:1] fname;
  initial begin
    fname = "b_18_1_1_dumpfile_variable.vcd";
    $dumpfile(fname);
    $dumpvars(0, a);
    a = 1'b0;
    #1 a = 1'b1;
    $finish(0);
  end
endmodule
