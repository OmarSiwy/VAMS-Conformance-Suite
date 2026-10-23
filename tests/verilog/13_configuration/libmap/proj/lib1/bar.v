// IEEE 1364-2005 §13.7.3's /proj/lib1/bar.v. Support source for the
// 13_configuration/b_13_2_* cases.
module bar;
  parameter D = 0;
  initial #D $display("%m %l");
endmodule
