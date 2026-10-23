// The design values.c reads and writes through vpi_get_value(),
// vpi_put_value() and vpi_get_time() (IEEE 1364-2005 §27.12, §27.14, §27.32).
// It prints nothing; every number is asserted from C.
//
// `timescale 1us/1ns and no other module, so the simulation time unit (the
// smallest precision) is 1 ns and one vpiSimTime tick is 1 ns, while the
// module's own unit is 1 us: a scaled real time of 1.5 here is 1500 ticks.
//
// t=0      every reg below takes its value; the application writes from a
//          cbReadWriteSynch at t=0.
// t=8 us   d: 8'h01 -> 8'h02, so the continuous assignment drives wn again.
// t=20 us  $finish(0).
`timescale 1us/1ns

module b_27_values;
  parameter   P = 3;
  reg  [11:0] known, mixed;
  reg  [3:0]  xz;
  reg         one, hiz;
  reg  [39:0] text;
  reg  [63:0] wide;
  real        rp, rn, rq;
  integer     k, hits;
  time        tv;
  reg  [7:0]  q, p, c;
  reg  [7:0]  d;
  wire [7:0]  wn;
  event       ev;

  assign wn = d;
  always @ev hits = hits + 1;

  initial begin
    known = 12'ha71;
    mixed = 12'b1010_zzzz_01x1;
    xz    = 4'b1x1z;
    one   = 1'b1;
    hiz   = 1'bz;
    text  = "VerA!";
    wide  = 64'h00000001FFFFFFFF;
    rp    = 2.5;
    rn    = -2.5;
    rq    = 1.25;
    k     = -7;
    tv    = 64'd5000000000;
    q = 0; p = 0; c = 0;
    d     = 8'h01;
    hits  = 0;
    #8 d  = 8'h02;
  end

  initial #20 $finish(0);
endmodule
