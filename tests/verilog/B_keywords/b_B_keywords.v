// IEEE 1364-2005 Annex B, p. 510: "Keywords are predefined nonescaped
// identifiers that define Verilog language constructs. An escaped identifier
// shall not be treated as a keyword." The list that follows is the whole set;
// its note: "unsigned is reserved for possible future usage."
//
// Escaped keywords are ordinary identifiers: \module, \wire, \begin and
// \unsigned name three regs and a wire here, and \signed a parameter.
// Words that are not on the list are not keywords: branch, ground, discipline
// and analog name four regs. Verilog-AMS reserves those four, and VerA
// compiles Verilog-AMS unless told otherwise, so the run selects IEEE
// 1364-2005 (`--std=1364-2005`, VerA's form of §19.11's
// `begin_keywords "1364-2005"`).
// §3.7.2, p. 14 (quoted for context): "A Verilog HDL keyword preceded by an
// escape character is not interpreted as a keyword." §3.7.1, p. 14:
// "Neither the leading backslash character nor the terminating white space is
// considered to be part of the identifier."
// \module = 1, \begin = 2, \unsigned = 3, \wire = \module + \begin = 3,
// \signed = 4; branch + ground + discipline + analog = 1 + 2 + 3 + 4 = 10.
// Output: "3 4 3 10".
//@ std 1364-2005
//! inherited IEEE 1364-2005 B
`timescale 1ns/1ns
module b_B_keywords;
  parameter \signed = 4;
  reg [3:0] \module , \begin , \unsigned ;
  wire [3:0] \wire ;
  reg [3:0] branch, ground, discipline, analog;
  assign \wire = \module + \begin ;
  initial begin
    \module = 1;
    \begin = 2;
    \unsigned = 3;
    branch = 1;
    ground = 2;
    discipline = 3;
    analog = 4;
    #1 $display("%0d %0d %0d %0d", \wire , \signed , \unsigned , branch + ground + discipline + analog);
    $finish(0);
  end
endmodule
