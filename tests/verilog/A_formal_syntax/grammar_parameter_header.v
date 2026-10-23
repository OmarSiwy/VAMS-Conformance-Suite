// IEEE/AMS A.1.3: nonempty parameter header with two declarations, empty
// module port list. Distinct defaults must be available in the module body.
// Empty () ports remain derivable in AMS via nullable non-ANSI port.
//! inherited IEEE 1364-2005 A.1.3
//! expect stdout grammar_parameter_header.expected.txt
module audit_grammar_parameter_header #(parameter A=3, parameter B=7) ();
  initial begin $display("%0d %0d",A,B); $finish(0); end
endmodule
