//! inherited IEEE 1364-2005 8 A.5.4
//! reject a UDP instance connects its terminals by position
// A UDP's terminals are connected by position, not by port name (pr938b).
primitive triage_pass (o, i);
  output o;
  input i;
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive

module triage_udp_named_terminal_rejected;
  reg i;
  wire o;

  triage_pass u(.o(o), .i(i));
endmodule
