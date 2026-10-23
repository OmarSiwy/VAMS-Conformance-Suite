//! inherited IEEE 1364-2005 19.5
// §19.5 leaves where a relative `include is searched to the tool; VerA
// searches the including file's directory, so this sibling is found though
// the run's working directory is elsewhere (include1/include2/include3).
`include "triage_include_relative_target.vh"
module triage_include_relative_file;
  initial if (`TRIAGE_INCLUDED_VALUE) $display("PASSED"); else $display("FAILED");
endmodule
