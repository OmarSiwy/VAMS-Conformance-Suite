//! inherited IEEE 1364-2005 19.5
//! reject `include file name must be quoted
// Syntax 19-6 takes a string literal file name; a macro there is IEEE 1800
// §22.4's addition (pr3012758).
`define TESTFILE "triage_include_target.v"
`include `TESTFILE
module triage_include_macro_file_name_rejected;
endmodule
