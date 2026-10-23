//! inherited IEEE 1364-2005 15.5.1
// $setuphold's delayed_reference and delayed_data arguments (8 and 9) are
// legal: C and BL_X[0] here (pr1520314).
module triage_setuphold_delayed_args(A, B, C, D, E, F);
  input A, B, D, E, F;
  output C;
  wire A, B, D, E, F;
  reg C;
  wire [1:0] BL;
  wire [1:0] BL_X;

  assign BL[0] = E;
  assign BL_X[0] = F;
  wire BL_0 = BL[0];
  wire BL_X_0 = BL_X[0];

  specify
    $setuphold(posedge A &&& B, BL[0], 0, 0, C, , , D, BL_X[0]);
  endspecify

  initial #1 $display("PASSED");
endmodule
