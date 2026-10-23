//! inherited IEEE 1364-2005 17.1.1
//! reject unterminated display format
// §17.1.1 does not say what a malformed format does; VerA refuses a trailing
// lone % (eofmt_percent).
module triage_malformed_format_trailing_percent_rejected;
  initial $display("The following should be a single percent: %");
endmodule
