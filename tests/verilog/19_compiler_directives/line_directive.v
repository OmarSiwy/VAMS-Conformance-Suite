// IEEE 1364-2005 §19.7, p. 357: "The `line directive shall set the line
// number and filename of the following line to those specified in the
// directive. The directive can be specified anywhere within the Verilog HDL
// source description. However, only white space may appear on the same line
// as the `line directive." ... "The number parameter shall be a positive
// integer that specifies the newline number of the following text line. The
// filename parameter shall be a string constant that is treated as the new
// name of the file. ... The level parameter shall be 0, 1, or 2." Its
// example: `line 3 "orig.v" 2
//
// The directive changes only the location the tool records (for its
// messages and for PLI), never what the design computes. The clause's
// example and one directive of each other level, one of them inside the
// initial block ("anywhere"), leave the module as it is without them:
// v = 5, then v + 1 -> "v=6".
//! inherited IEEE 1364-2005 19.7
`line 3 "orig.v" 2
module b_19_7_line_directive;
  integer v;
`line 20 "parts/count.v" 1
  initial begin
    v = 5;
`line 7 "orig.v" 0
    $display("v=%0d", v + 1);
    $finish(0);
  end
endmodule
