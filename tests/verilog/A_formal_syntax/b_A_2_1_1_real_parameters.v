// IEEE 1364-2005 A.2.1.1, p. 489:
//   local_parameter_declaration ::= ... | localparam parameter_type list_of_param_assignments
//   parameter_declaration ::= ... | parameter parameter_type list_of_param_assignments
//   parameter_type ::= integer | real | realtime | time
//
// The two real-valued parameter_types: LR = 2.5 (localparam real) and
// PT = 1.25 (parameter realtime). Output: "LR=2.50 PT=1.25".
//! inherited IEEE 1364-2005 A.2.1.1
module b_A_2_1_1_real_parameters;
  localparam real LR = 2.5;
  parameter realtime PT = 1.25;
  initial begin
    $display("LR=%.2f PT=%.2f", LR, PT);
    $finish(0);
  end
endmodule
