// IEEE1364-2005 §11.6.3: blocking intra-assignment delay samples RHS
// before suspension but chooses indexed LHS at resumption. At1 RHS=1,
// index0; at2 source=0,index2; at5 resumption writes captured1 to bit2.
// This complements, not replaces, the existing NBA index-snapshot fixture.
//! inherited IEEE 1364-2005 11.6.3
`timescale 1ns/1ns
module audit_sched_blocking_target_return;
  reg [3:0] q;
  reg source;
  integer index;
  initial begin
    q = 0; source = 1; index = 0;
    #1 q[index] = #4 source;
    $display("returned=%b", q);
    #1 $finish(0);
  end
  initial begin
    #2 source = 0; index = 2;
    #1 $display("pending=%b", q);
  end
endmodule
