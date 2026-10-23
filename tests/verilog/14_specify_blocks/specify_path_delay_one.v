//! inherited IEEE 1364-2005 14
// A module path delay applies: o follows i one time unit later even though
// the continuous assignment is immediate (br1006).
module triage_path_dut(input i, output o);
  assign o = i;

  specify
    (i => o) = (1, 1);
  endspecify
endmodule

module triage_specify_path_delay_one;
  reg i;
  wire o;
  reg failed = 0;

  triage_path_dut dut(i, o);

  initial begin
    #1 i = 1'b1;
    #0 if (o !== 1'bx) failed = 1;
    #1 i = 1'b0;
    #0 if (o !== 1'b1) failed = 1;
    #1;
    #0 if (o !== 1'b0) failed = 1;
    #1;

    if (failed) $display("FAILED");
    else $display("PASSED");
  end
endmodule
