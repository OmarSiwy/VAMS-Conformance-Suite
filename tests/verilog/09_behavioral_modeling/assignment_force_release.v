// IEEE1364-2005 §9.3.2: release of an ordinary variable retains the forced
// value until another procedural write; release of a net restores its drivers.
// Force RHS is reevaluated while active. No exact-time race is sampled.
//! inherited IEEE 1364-2005 9.3.2
module audit_assignment_force_release;
  reg source, variable;
  wire netvalue;
  assign netvalue = source;
  initial begin
    source = 0; variable = 0;
    #1 force variable = ~source;
    force netvalue = ~source;
    #1 $display("forced=%b,%b", variable, netvalue);
    source = 1;
    #1 $display("reevaluated=%b,%b", variable, netvalue);
    release variable;
    release netvalue;
    #1 $display("released=%b,%b", variable, netvalue);
    variable = 1;
    #1 $display("procedural_write=%b", variable);
    $finish(0);
  end
endmodule
