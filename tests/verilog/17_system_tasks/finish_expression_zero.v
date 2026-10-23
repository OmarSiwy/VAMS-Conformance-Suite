// IEEE1364-2005 17.4.1 allows an expression selecting verbosity0/1/2.
// This runtime integer expression is0: finish prints nothing and terminates
// execution; the later statement must not execute. This is not a host exit
// status argument. No diagnostics/statistics wording is constrained here.
//! lrm 9.7.1
//! inherited IEEE 1364-2005 17.4.1
//! expect stdout finish_expression_zero.expected.txt
module audit_finish_expression_zero;
  integer verbosity;
  initial begin
    verbosity = 0;
    $display("before");
    $finish(verbosity);
    $display("after");
  end
endmodule
