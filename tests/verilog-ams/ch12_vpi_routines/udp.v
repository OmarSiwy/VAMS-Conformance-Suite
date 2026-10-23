// The design seq_udp.c runs (VAMS-2023 12.30): a sequential UDP instance
// with a delay. No `//!` directive, so the suite does not collect it
// (tests/suite.zig `fixtureExt`).
//
// b7_latch is IEEE 1364 §8's level-sensitive latch shape, its output 0 from
// the start (§8.1.3: "The sequential UDP initial statement specifies the
// value of the output port when simulation begins"). en is 0 from t=0 and
// never changes, and the `? 0 : ? : -` row holds the state, so nothing in the
// design moves q off 0: whatever its #5 does to the initial value, q is 0 by
// t=5 and stays 0. The instance carries #5.
//
// THE TIMELINE: d = 0, en = 0 at t=0; $finish at 20.
`timescale 1ns/1ns

primitive b7_latch (q, d, en);
  output q;
  reg q;
  input d, en;
  initial q = 0;
  table
  // d en : q : q+
     1  1 : ? : 1;
     0  1 : ? : 0;
     ?  0 : ? : -;
  endtable
endprimitive

module b7_udp;
  reg  d, en;
  wire q;

  b7_latch #5 lat (q, d, en);

  initial begin
    d = 0; en = 0;
    #20 $finish(0);
  end
endmodule
