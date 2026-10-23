// IEEE 1364-2005 §18.1.2 Syntax 18-3: every argument after the level count is
// a `module_or_variable ::= module_identifier | variable_identifier`. `nosuch`
// names neither a module instance nor a variable of this design, so the
// call has no scope to dump and is refused before anything runs (and before
// any dump file is created).
//! inherited IEEE 1364-2005 18.1.2
//! reject $dumpvars names a module instance or a variable
module d09_dumpvars_unknown;
  reg a;
  initial begin
    $dumpvars(0, nosuch);
    a = 1'b0;
  end
endmodule
