// The design readwrite_inactive.c runs (VAMS-2023 8.5.1). No `//!`
// directive, so the suite does not collect it; every number about it is
// asserted from C.
//
// THE TIMELINE (t in ns): at t=0 both regs are 0. At t=7 the one process
// resumes, does a blocking `b = 8'h11` (an active event) and a nonblocking
// `r <= 8'h42` (a nonblocking assign update event), then ends. $finish at 20.
`timescale 1ns/1ns

module b8_readwrite_inactive;
  reg [7:0] r, b;

  initial begin
    r = 8'h00;
    b = 8'h00;
    #7;
    b = 8'h11;
    r <= 8'h42;
  end

  initial #20 $finish(0);
endmodule
