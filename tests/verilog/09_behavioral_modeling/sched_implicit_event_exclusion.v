// IEEE1364-2005 9.7.5: gate appears only in an event expression, so only
// data_bit is in the OUTER implicit list. After one completed copy, independent
// destination0 poke and two gate changes must not start a second copy.
// A later data change arms the inner event and its next gate change copies0.
//! lrm 8.5
//! inherited IEEE 1364-2005 9.7.5
`timescale 1ns/1ns
module audit_sched_implicit_event_exclusion;
  reg gate, data_bit, destination;
  always @* begin
    @(gate) destination = data_bit;
  end
  initial begin
    #1 data_bit = 1;
    #1 gate = 1;
    #1 destination = 0;
    #1 gate = 0;
    #1 gate = 1;
    #1 $display("gate-only=%b", destination);
    destination = 1;
    #1 data_bit = 0;
    #1 gate = 0;
    #1 $display("data-then-gate=%b", destination);
    $finish(0);
  end
endmodule
