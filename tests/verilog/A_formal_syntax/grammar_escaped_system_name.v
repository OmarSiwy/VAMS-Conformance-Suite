// IEEE 1364-2005 A.9.3 and Details4 distinguish ordinary escaped names
// from system identifiers. Backslash and terminating space are not name bytes.
// Assigning ordinary escaped $time cannot change the simulation time function.
// All execution is at time0: the stored byte is9, genuine $time is0.
//! inherited IEEE 1364-2005 A.9.3 3.7.1 17.7.1
//! expect stdout grammar_escaped_system_name.expected.txt
`timescale 1ns/1ps
module audit_grammar_escaped_system_name;
  reg [7:0] \$time ;
  initial begin
    \$time = 8'd9;
    $display("ordinary=%0d system=%0d", \$time , $time);
    $finish(0);
  end
endmodule
