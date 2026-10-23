// IEEE 1364-2005 §17.3.1, p. 299: "When an argument is specified,
// $printtimescale displays the time unit and precision of the module passed
// to it." ... "In this example, module a_dat invokes the $printtimescale
// system task to display timescale information about another module c_dat,
// which is instantiated in module b_dat. The information about c_dat shall be
// displayed in the following format: Time scale of (b_dat.c1) is 1ns / 1ns"
//
// The clause's example, with one change: its a_dat and b_dat are both
// top-level modules, and VerA elaborates one top, so here the top module
// instantiates b_dat as b and names the instance by its full path,
// b_17_3_1_printtimescale_named_module.b.c1. As in the clause, the printed
// name is the argument the call was handed (the example prints "b_dat.c1",
// its argument, a full path because b_dat is a top). c1 is a c_dat, whose
// `timescale is 1 ns / 1 ns, so its unit is 1ns and its precision 1ns; the
// caller's own 1 ms / 1 us and b_dat's 10 fs / 1 fs are not what is asked:
//   Time scale of (b_17_3_1_printtimescale_named_module.b.c1) is 1ns / 1ns
//! inherited IEEE 1364-2005 17.3.1
`timescale 1 ms / 1 us
module b_17_3_1_printtimescale_named_module;
  b_17_3_1_printtimescale_named_module_b b ();
  initial begin
    $printtimescale(b_17_3_1_printtimescale_named_module.b.c1);
    $finish(0);
  end
endmodule
`timescale 10 fs / 1 fs
module b_17_3_1_printtimescale_named_module_b;
  b_17_3_1_printtimescale_named_module_c c1 ();
endmodule
`timescale 1 ns / 1 ns
module b_17_3_1_printtimescale_named_module_c;
endmodule
