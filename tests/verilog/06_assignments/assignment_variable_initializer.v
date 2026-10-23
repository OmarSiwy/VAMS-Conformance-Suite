// IEEE1364-2005 §6.2.1: declaration initialization is one procedural write,
// not a continuous driver. No competing time-zero writes to the initialized
// reg are used. A later procedural assignment replaces its value; the net
// declaration assignment tracks that change (§6.1.1).
//! inherited IEEE 1364-2005 6.1.1 6.2.1
module audit_assignment_variable_initializer;
  reg [7:0] value = 2*3+1;
  wire [7:0] observed = value;
  initial begin
    #1 $display("initialized=%0d net=%0d", value, observed);
    value = 12;
    #1 $display("replaced=%0d net=%0d", value, observed);
    $finish(0);
  end
endmodule
