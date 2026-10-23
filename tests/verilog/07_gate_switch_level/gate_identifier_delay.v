//! inherited IEEE 1364-2005 7.14 A.2.2.3
// delay3's delay_value may be an identifier, so buf #d (g, in) is a gate with
// delay d, not a call (delay_var).
module triage_gate_identifier_delay;
  parameter d = 2;
  reg in;
  wire g;

  buf #d (g, in);

  initial begin
    in = 0;
    #3 $display("%b", g);
    in = 1;
    #3 $display("%b", g);
  end
endmodule
