//! inherited IEEE 1364-2005 8 A.5.4
//! reject UDP instance connects its terminals by position
// A UDP instance connects terminals by position only, each an expression; an
// empty trailing terminal is not 1364 (pr707).
primitive mux (x, s, a, b, f);
  output x;
  input s, a, b, f;
  table
    0 1 ? ? : 1;
    0 0 ? ? : 0;
    1 ? 1 ? : 1;
    1 ? 0 ? : 0;
    x 0 0 ? : 0;
    x 1 1 ? : 1;
  endtable
endprimitive

module triage_udp_null_terminal_rejected;
  reg r1, r2, r3;
  wire w1;

  mux udp1(w1, r1, r2, r3, );
endmodule
