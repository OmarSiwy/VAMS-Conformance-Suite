//! inherited IEEE 1364-2005 6.1.3 7.14 A.2.2.3
// delay3's parentheses hold mintypmax_expressions, not constants, so a gate
// instance may take a variable delay: buf #(d) schedules with d's value when
// its input changes (verify_two_var_delays).
module triage_gate_variable_delay;
  reg [31:0] d;
  reg in;
  wire out;

  buf #(d) g(out, in);

  initial begin
    d = 3;
    in = 0;
    #4 $display("t4 %b", out);
    in = 1;
    #4 $display("t8 %b", out);
  end
endmodule
