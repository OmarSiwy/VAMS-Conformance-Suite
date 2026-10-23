// The design 10_systf_digital.c registers system tasks and functions against.
//
// Everything here is shaped so a COUNT is derivable. LRM 12.33.1 separates two
// rates — "Callbacks to the applications pointed to by the compiletf and sizetf
// fields shall occur when the simulation data structure is compiled or built"
// (once per CALL SITE) versus "Callbacks to the application pointed to by the
// calltf routine shall occur each time the system task or function is invoked
// during simulation execution" (once per EXECUTION). A design in which those
// two numbers are equal cannot tell the two apart, so $p02_sum appears at two
// call sites and one of them runs three times: 2 compiletf against 4 calltf.
//
// The loop index `i` is passed as the second argument of the looping call site
// so that the argument handles a calltf reads are re-read each invocation
// rather than frozen at build time: the three loop invocations must see 0, 1
// and 2.
//
// `timescale 1ns/1ns, matching design.v, so the whole P02 set shares one
// simulation time unit.

`timescale 1ns/1ns

module p02_systf;

  reg [31:0] r;       // last $p02_sum result: $p02_sum(10, 2) = 12
  reg [39:0] sized;   // $p02_wide, a vpiSizedFunc with a sizetf answering 40
  reg [31:0] deflt;   // $p02_plain, a vpiSizedFunc with NO sizetf: 32 bits
  integer    i;

  initial begin
    r = $p02_sum(3, 4);                 // call site 1, runs once  -> 7
    for (i = 0; i < 3; i = i + 1)
      r = $p02_sum(10, i);              // call site 2, runs 3x    -> 10, 11, 12
    $p02_note("hello");                 // call site 3, a task
    sized = $p02_wide;                  // call site 4
    deflt = $p02_plain;                 // call site 5
  end

endmodule
