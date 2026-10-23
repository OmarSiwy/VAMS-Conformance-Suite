// The design put_delays.c runs (VAMS-2023 12.29 vpi_put_delays): a
// delayed continuous assignment and a two-delay buffer, both following `a`,
// which is 0 from time 0, 1 at 10 and 0 at 30.
//
// As WRITTEN — the delays vpi_get_delays reports before any put:
//     assign #5 w = a;       w: 0 at 5, 1 at 15, 0 at 35
//     buf #(4,6) (y, a);     y: 0 at 6 (fall), 1 at 14 (rise), 0 at 36
// The application puts #2 on the assignment and #(1,3) on the buffer before
// time 0, so the transitions it observes are the PUT delays':
//     w: 0 at 2, 1 at 12, 0 at 32        y: 0 at 3, 1 at 11, 0 at 33
`timescale 1ns/1ns

module p05_delays;
  reg a;
  wire w, y;

  assign #5 w = a;
  buf #(4,6) (y, a);

  initial begin
    a = 0;
    #10 a = 1;
    #20 a = 0;
    #20 $finish(0);
  end
endmodule
