//! inherited IEEE 1364-2005 8.1.4
//! reject E0248
// The same input combination may not be given different outputs: `1 : 1` and
// `? : 0` both cover input 1 (pr3587570).
primitive triage_pass (o, i);
  output o;
  input i;
  table
    1 : 1;
    0 : 0;
    ? : 0;
  endtable
endprimitive

module triage_udp_conflicting_rows_rejected;
  reg i;
  wire o;

  triage_pass u(o, i);
endmodule
