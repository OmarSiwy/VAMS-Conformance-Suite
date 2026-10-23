// IEEE 1364-2005 §18.3.1, p. 338: "The $dumpports task shall be used to
// specify the name of the VCD file and the ports to be dumped." Syntax 18-21:
// `$dumpports ( scope_list , file_pathname ) ;`. p. 339: "All the ports in
// the model from the point of the $dumpports call are considered primary I/O
// pins and shall be included in the VCD file."
// §18.3.5, p. 341: "The $dumpportsflush system task writes all port values to
// the associated file, clearing a simulator's VCD buffer."
// §18.3, p. 338: "The four-state VCD file rules and syntax apply to the
// extended VCD file unless otherwise stated in this subclause." §18.4, p.
// 342: "The format of the extended VCD file is similar to that of the
// four-state VCD file, as it is also structured in a free format." §18.4.1,
// Syntax 18-27 (p. 343): `* var_type ::= port`, `* size ::= 1 | vector_index`,
// `* identifier_code ::= <{integer}`.
// §18.4.2, pp. 344-345: "var_type The keyword port. No other keyword is
// allowed." "size ... If the port is a single bit, the value shall be 1. If
// the port is a bus, the actual index is printed." "identifier_code An
// integer preceded by <, which starts at zero and ascends in one-unit
// increments for each port, in the order found in the module declaration."
// "reference Identifier indicating the port name." "If the vector_index
// appears in the port declaration, this shall be the index dumped."
//
// This is §18.4.2's own example: module test_device(count_out, carry, data,
// reset), `output count_out, carry; input [0:3] data; input reset;`, dumped
// by `$dumpports(testbench.DUT, "testoutput.vcd")` (the file renamed here),
// for which the clause gives the node information:
//   $scope module testbench.DUT $end
//   $var port 1 <0 count_out $end
//   $var port 1 <1 carry $end
//   $var port [0:3] <2 data $end
//   $var port 1 <3 reset $end
//   $upscope $end
//
// The dump is read back during the simulation after $dumpportsflush, split
// into white-space separated tokens ("At least one space shall separate each
// syntactical element"), and the tokens from the first $scope through
// `$enddefinitions $end` are printed one per line: the example above, then
// `$enddefinitions $end`. (Dumping starts at the end of time 0; the reader
// runs at #1.)
//! inherited IEEE 1364-2005 18.3 18.3.1 18.3.5 18.4 18.4.1 18.4.2
// native-required
`timescale 1ns/1ns
module test_device(count_out, carry, data, reset);
  output count_out, carry;
  input [0:3] data;
  input reset;
  assign count_out = reset;
  assign carry = ^data;
endmodule

module testbench;
  reg [0:3] data;
  reg reset;
  wire count_out, carry;
  test_device DUT(count_out, carry, data, reset);
  integer fd, c, len, printing, done;
  reg [8*64:1] tok;

  task token;
    begin
      if (tok == "$scope") printing = 1;
      if (printing && !done) $display("%0s", tok);
      if (printing && tok == "$enddefinitions") printing = 2;
      else if (printing == 2 && tok == "$end") done = 1;
    end
  endtask

  initial begin
    data = 4'b0101;
    reset = 1'b1;
    $dumpports(testbench.DUT, "b_18_4_2_node.evcd");
    #1 $dumpportsflush("b_18_4_2_node.evcd");
    fd = $fopen("b_18_4_2_node.evcd", "r");
    printing = 0;
    done = 0;
    tok = 0;
    len = 0;
    c = $fgetc(fd);
    while (c != -1) begin
      if (c == " " || c == "\n" || c == "\t" || c == 8'd13) begin
        if (len != 0) token;
        tok = 0;
        len = 0;
      end else begin
        tok = {tok, c[7:0]};
        len = len + 1;
      end
      c = $fgetc(fd);
    end
    if (len != 0) token;
    $fclose(fd);
  end
endmodule
