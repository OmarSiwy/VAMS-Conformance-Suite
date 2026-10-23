// AMS2.8.1/6.7: the dot inside an escaped instance name belongs to that
// identifier; the dot after its whitespace terminator is the path separator.
// Independent child state is observed at time1, after both initial writes.
//! lrm 2.8.1
//! lrm 6.7
//! expect stdout ams_lexical_escaped_hierarchy.expected.txt
//! inherited IEEE 1364-2005 3.7.1 12.5
`timescale 1ns/1ps
module audit_ams_lexical_escaped_hierarchy;
  lexical_child \a.b ();
  lexical_child ordinary();
  initial begin
    #1;
    $display("%0d %0d", \a.b .value, ordinary.value);
  end
endmodule
module lexical_child;
  integer value;
  initial value = 9;
endmodule
