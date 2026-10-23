// IEEE 1364-2005 §17.2.3, p. 290: "The remaining arguments to $sformat are
// processed using any format specifiers in the format_string, until all such
// format specifiers are used up. If not enough arguments are supplied for the
// format specifiers or too many are supplied, then the application shall
// issue a warning and continue execution."
//
// The same page: "The application, if possible, can statically determine a
// mismatch in format specifiers and number of arguments and issue a compile
// time error message." So the format is a variable, fmt = "%0d", assigned at
// run time: one specifier, and two arguments follow it, too many. The run
// must warn and continue, so the $display after it prints "continued". What
// s holds afterwards is not fixed by the clause, so it is not printed.
//! inherited IEEE 1364-2005 17.2.3
// native-required
module b_17_2_3_sformat_excess_argument_warning;
  reg [8*8:1] s;
  reg [8*3:1] fmt;
  initial begin
    fmt = "%0d";
    $sformat(s, fmt, 1, 2);
    $display("continued");
    $finish(0);
  end
endmodule
