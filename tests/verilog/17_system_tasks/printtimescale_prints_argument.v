//! inherited IEEE 1364-2005 17.3.1
// The module name $printtimescale prints is not fixed as full or as written;
// VerA prints the argument as handed to it (pr1701855).
`timescale 1ns/1ns
module triage_printtimescale_prints_argument;
  dut_triage d();

  initial begin
    $printtimescale(d);
    $finish(0);
  end
endmodule

`timescale 1ns/1ns
module dut_triage;
endmodule
