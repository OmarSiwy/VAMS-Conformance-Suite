// IEEE1364-2005 §9.3.1: procedural assign continuously overrides procedural
// writes; deassign retains the last assigned value until the next write.
//! inherited IEEE 1364-2005 9.3.1
module audit_assignment_assign_deassign;
  reg source, value;
  initial begin
    source = 0; value = 1;
    assign value = source;
    #1 $display("assigned=%b", value);
    value = 1;
    #1 $display("override=%b", value);
    source = 1;
    #1 $display("reevaluated=%b", value);
    deassign value;
    source = 0;
    #1 $display("held=%b", value);
    value = 0;
    #1 $display("new_write=%b", value);
    $finish(0);
  end
endmodule
