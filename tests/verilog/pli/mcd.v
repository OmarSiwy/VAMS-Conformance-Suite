// The design mcd.c shares descriptors with (IEEE 1364-2005 §27.24-§27.26):
// one multichannel descriptor and one file descriptor, both opened by the HDL
// at t=0 and left open, so the application finds them in `hm` and `hf`. Both
// files land in the run's working directory.
`timescale 1ns/1ns

module b_27_mcd;
  integer hm, hf;

  initial begin
    hm = $fopen("b_27_mcd_hdl.log");
    hf = $fopen("b_27_mcd_fd.log", "w");
    #1 $finish(0);
  end
endmodule
