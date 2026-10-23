// The design the b7 digital applications run: buffers.c, cb_fields.c,
// printf_log.c and the four b7_sim_control_*.c (VAMS-2023 12.4, 12.12,
// 12.16, 12.25, 12.28, 12.31.1, 12.36). No `//!` directive, so the suite does
// not collect it (tests/suite.zig `fixtureExt`); every number about it is
// asserted from C.
//
// `timescale 1ns/1ns and nothing finer, so one vpiSimTime tick is 1 ns.
//
// THE TIMELINE (t in ns):
//   t=0  the named block `seq` runs `alpha = 8'h01` (its first statement),
//        `beta = 8'h02`, `w40 = 0`.
//   t=2  w40: 0 -> 40'h12_3456_789A                      (value change)
//   t=4  w40: -> 40'hA5_zzzz_xxxx: bits 39..32 = A5, bits 31..16 z,
//        bits 15..0 x                                    (value change)
//   t=10 $finish(0).
// The module has exactly three regs (alpha, beta, w40); `seq` declares none.
`timescale 1ns/1ns

module b7_digital;
  reg [7:0]  alpha, beta;
  reg [39:0] w40;

  initial begin : seq
    alpha = 8'h01;
    beta  = 8'h02;
    w40   = 40'h00_0000_0000;
    #2 w40 = 40'h12_3456_789A;
    #2 w40 = 40'hA5_zzzz_xxxx;
  end

  initial #10 $finish(0);
endmodule
