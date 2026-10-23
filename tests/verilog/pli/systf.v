// The design systf.c overrides built-ins in (IEEE 1364-2005 §20.4):
// four system calls, each a built-in name, so the source elaborates whether
// or not the override takes. The application reads every result back through
// VPI; the design prints nothing.
//
// Call sites, in source order (§26.1.2 counts them):
//   1  $unsigned(1'b1)       inside a loop that runs twice (§26.1.3 counts 2)
//   2  $unsigned(64'h0)      runs once
//   3  $signed(4'sb1000)     runs once
//   4  $realtime             runs once
//   5  $monitoroff           runs once
`timescale 1ns/1ns

module b_26_1_systf;
  reg  [39:0] a, b;
  reg  [15:0] c;
  real        t;
  integer     k;

  initial begin
    for (k = 0; k < 2; k = k + 1)
      a = $unsigned(1'b1);
    b = $unsigned(64'h0);
    c = $signed(4'sb1000);
    t = $realtime;
    $monitoroff;
    #1 $finish(0);
  end
endmodule
