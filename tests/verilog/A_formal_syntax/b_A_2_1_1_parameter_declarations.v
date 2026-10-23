// IEEE 1364-2005 A.2.1.1, p. 489:
//   local_parameter_declaration ::=
//       localparam [ signed ] [ range ] list_of_param_assignments
//     | localparam parameter_type list_of_param_assignments
//   parameter_declaration ::=
//       parameter [ signed ] [ range ] list_of_param_assignments
//     | parameter parameter_type list_of_param_assignments
//   specparam_declaration ::= specparam [ range ] list_of_specparam_assignments ;
//   parameter_type ::= integer | real | realtime | time
//
// Every alternative once; the real and realtime parameter_types are
// b_A_2_1_1_real_parameters.v:
//   localparam signed [3:0] LS = 4'b1110   printed in binary: 1110
//   localparam integer LI = 7, LJ = LI + 1  7, 8 (a list of two)
//   parameter P = 3                         no signed, no range
//   parameter [7:0] PR = 8'hF0              240
//   parameter time PM = 64'd9               9
//   specparam [3:0] SR = 4'd5               5
//   specparam SP = 6
// Output: "LS=1110 LI=7 LJ=8 P=3 PR=240 PM=9 SR=5 SP=6".
//! inherited IEEE 1364-2005 A.2.1.1
module b_A_2_1_1_parameter_declarations;
  localparam signed [3:0] LS = 4'b1110;
  localparam integer LI = 7, LJ = LI + 1;
  parameter P = 3;
  parameter [7:0] PR = 8'hF0;
  parameter time PM = 64'd9;
  specparam [3:0] SR = 4'd5;
  specparam SP = 6;
  initial begin
    $display("LS=%b LI=%0d LJ=%0d P=%0d PR=%0d PM=%0d SR=%0d SP=%0d",
             LS, LI, LJ, P, PR, PM, SR, SP);
    $finish(0);
  end
endmodule
