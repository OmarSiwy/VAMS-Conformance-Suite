// IEEE 1364-2005 §17.10, p. 320: "These arguments, referred to below as
// plusargs, are accessible through the system functions described in
// 17.10.1 and 17.10.2." §17.10.1, p. 320: "The string is specified in the
// argument to the system function as either a string or a nonreal variable
// that is interpreted as a string." ... "If no plusarg from the command line
// matches the string provided, the function returns the integer value zero."
// §17.10.2, p. 321: "If no string is found matching, the function returns the
// integer value zero, and the variable provided is not modified."
//
// The run is given no plusargs, so every query finds no match. The query
// strings are held in reg variables, the form test_plusargs_absent.v
// and value_plusargs_absent.v leave out (they pass literals):
//   name = "HELLO": $test$plusargs(name) -> 0
//   fmt = "N=%d":   $value$plusargs(fmt, v) -> 0, and v keeps 42
//! inherited IEEE 1364-2005 17.10 17.10.1 17.10.2
`timescale 1 ns / 1 ns
module b_17_10_1_plusargs_variable_query;
  reg [8*5:1] name;
  reg [8*4:1] fmt;
  integer v, r;
  initial begin
    name = "HELLO";
    fmt = "N=%d";
    v = 42;
    r = $test$plusargs(name);
    $display("test=%0d", r);
    r = $value$plusargs(fmt, v);
    $display("value=%0d v=%0d", r, v);
    $finish(0);
  end
endmodule
