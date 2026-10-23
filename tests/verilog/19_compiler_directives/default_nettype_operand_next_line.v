//! inherited IEEE 1364-2005 19.2
// A directive's operand need not be on the directive's own line; the newline
// is white space (br_gh782f).
`default_nettype
wire
module triage_default_nettype_operand_next_line;
  assign out = 1'b1;

  initial #1 if (out === 1'b1) $display("PASSED"); else $display("FAILED");
endmodule
