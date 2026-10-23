//! inherited IEEE 1364-2005 7.1.6
//! reject a gate's input terminal is one bit
// §7.1.6 sizes terminals only for instance arrays; a multi-bit expression on
// a single gate's input is unspecified, and VerA refuses it (gate_connect1).
module triage_gate_multibit_input_rejected;
  reg [1:0] in;
  wire out;

  buf b(out, in);

  initial in = 2'b01;
endmodule
