// The digital design the P02 value/scheduling/callback applications run against.
//
// Not a tests/fixtures/** file: a fixture there asserts a number a compiled
// analog device produces. Every number this file is about is asserted from C,
// by the applications in this directory, through vpi_get_value()/
// vpi_put_value()/vpi_register_cb(). The design's only job is to have a
// TIMELINE that is hand-derivable, so an application can say "at t=7 this reg
// reads 0x42 and at t=6 it did not" and be right for a reason.
//
// `timescale 1ns/1ns, and nothing finer anywhere in the P02 set, so the global
// simulation time unit is 1 ns and one tick of LRM 12.15's vpiSimTime is 1 ns.
// That is what makes `low == 7` at t=7 ns a derivation rather than a guess.
//
// THE TIMELINE, once and for all (t in ns):
//
//   t=0   all six initial blocks start. `known`, `unknown`, `bit1`, `bitz`,
//         `text`, `wide`, `qi`, `qt`, `qp`, `a`, `s`, `n`, `mem[*]`, `g` take
//         their time-0 values and never move again except as listed.
//   t=1   n: 0 -> 5   (value change #1);  mem[2]: 0x00 -> 0x7E
//   t=2   n: 5 -> 9   (value change #2)
//   t=3   n: 9 -> 9   (a WRITE, not a value CHANGE — no cbValueChange)
//   t=4   n: 9 -> 2   (value change #3)
//   t=5   g: 0x01 -> 0x02
//   t=6   a: 10 -> 20, so the continuous assignment drives w: 11 -> 21
//   t=7   s: 0x01 -> 0x42
//   t=10  g: 0x02 -> 0x03
//   t=20  g: 0x03 -> 0x04 and one $display. An application that calls
//         vpi_sim_control(vpiFinish, 0) before t=20 must prevent BOTH.
//   t=40  $finish(0) — the backstop so every application terminates.
//
// FUTURE-QUEUE CENSUS, used by 05_cb_time_regions.c against 11.6.25 NOTE 3.
// Every initial block runs to its first delay during t=0, so after time 0 the
// pending times are exactly {1, 5, 6, 7, 40}: the n block is at #1, the g block
// at #5, the a block at #6, the s block at #7, the backstop at #40, and the
// static block has already finished. The n block then re-queues itself at
// 2, 3 and 4 as it walks its own #1 steps.
//
// These are the times THIS DESIGN contributes. An application that registers a
// callback for a time not in the list above adds a time queue of its own —
// 11.6.25 puts a callback in a time queue tagged vpiParent — and must count it
// when it walks vpiTimeQueue. 05_cb_time_regions.c registers exactly one such
// time (t=33) and says so.

`timescale 1ns/1ns

module p02_design;

  // --- 01/02_get_value_*: written once at t=0, read for their bit patterns.
  reg [11:0] known;    // 12'ha71 = 2673
  reg [11:0] unknown;  // four z bits and one x bit, to exercise Table 12-4
  reg        bit1;     // a scalar 1, for vpiScalarVal
  reg        bitz;     // a scalar z
  reg [39:0] text;     // "VerA!" = 40'h5665724121, for vpiStringVal
  reg [63:0] wide;     // 64'h00000001FFFFFFFF, two s_vpi_vecval elements

  // --- 03_put_value_delays: never written by the design after t=0, so every
  // later transition on them is an application's own vpi_put_value().
  reg [7:0] qi, qt, qp;

  // --- 04_force_release: `w` is CONTINUOUSLY driven, so releasing a force on
  // it has a defined destination (the driver's value) rather than "whatever was
  // last procedurally assigned".
  reg  [7:0] a;
  wire [7:0] w;
  assign w = a + 8'd1;

  // --- 05_cb_time_regions: one transition, at one time, so "before the events
  // of t=7" and "after the events of t=7" are two different readings.
  reg [7:0] s;

  // --- 06_cb_value_change / 07_cb_remove_and_info: a scalar-ish reg with a deliberate non-change,
  // and a memory so 12.31.1's `index` field has something to report.
  reg [3:0] n;
  reg [7:0] mem [0:3];

  // --- 08_cb_action_sim_control: transitions straddling the moment the
  // application asks for $finish.
  reg [7:0] g;

  initial begin
    known   = 12'b1010_0111_0001;
    unknown = 12'b1010_zzzz_01x1;
    bit1    = 1'b1;
    bitz    = 1'bz;
    text    = 40'h5665724121;   // "VerA!"
    wide    = 64'h00000001FFFFFFFF;
    qi = 8'h00;
    qt = 8'h00;
    qp = 8'h00;
  end

  initial begin
    a = 8'd10;
    #6 a = 8'd20;
  end

  initial begin
    s = 8'h01;
    #7 s = 8'h42;
  end

  initial begin
    n = 4'd0;
    mem[0] = 8'h00;
    mem[1] = 8'h00;
    mem[2] = 8'h00;
    mem[3] = 8'h00;
    #1 n = 4'd5;
       mem[2] = 8'h7E;
    #1 n = 4'd9;
    #1 n = 4'd9;
    #1 n = 4'd2;
  end

  initial begin
    g = 8'h01;
    #5  g = 8'h02;
    #5  g = 8'h03;
    #10 g = 8'h04;
    $display("p02_design: t=20 reached");
  end

  initial #40 $finish(0);

endmodule
