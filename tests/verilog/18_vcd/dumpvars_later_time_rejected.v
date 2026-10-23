//! inherited IEEE 1364-2005 18.1.2
//! reject every $dumpvars shall execute at the same simulation time
// Every $dumpvars call shall execute at the same simulation time; calling it
// again at a later time is refused (pr2994193).
module triage_dumpvars_later_time_rejected;
  reg a;

  initial begin
    $dumpfile("triage_dumpvars_later.vcd");
    $dumpvars(0, a);
    #1 $dumpvars(0, a);
  end
endmodule
