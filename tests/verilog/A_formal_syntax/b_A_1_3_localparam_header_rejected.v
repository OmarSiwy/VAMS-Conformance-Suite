// IEEE 1364-2005 A.1.3 permits parameter_declaration in the header, whose
// A.2.1.1 production starts with parameter. local_parameter_declaration is
// distinct. grammar_parameter_header.v executes the legal header;
// parameter_assignment_forms.v in 12_hierarchy executes a body localparam.
//! inherited IEEE 1364-2005 A.1.3
//! reject E0246
//! neighbour grammar_parameter_header.v
module b_A_1_3_localparam_header #(localparam P=7) ();
  initial $display("invalid header was accepted: %0d",P);
endmodule
