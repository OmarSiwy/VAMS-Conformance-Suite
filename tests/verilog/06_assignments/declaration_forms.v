// IEEE 1364-2005 §6.2.2, Syntax 6-2, p. 73:
//   integer_declaration ::= integer list_of_variable_identifiers ;
//   real_declaration ::= real list_of_real_identifiers ;
//   realtime_declaration ::= realtime list_of_real_identifiers ;
//   reg_declaration ::= reg [ signed ] [ range ] list_of_variable_identifiers ;
//   time_declaration ::= time list_of_variable_identifiers ;
//   real_type ::= real_identifier { dimension }
//               | real_identifier = constant_expression
//   variable_type ::= variable_identifier { dimension }
//                   | variable_identifier = constant_expression
//   list_of_real_identifiers ::= real_type { , real_type }
//   list_of_variable_identifiers ::= variable_type { , variable_type }
//
// Every declaration kind appears; the reg, integer and real lists mix an
// initialized name, a plain name and an array (a name with a dimension).
// Read at time 1.
//   reg signed [7:0] rs = -8'sd3, ru, rm [0:1]  -> rs = -3, ru = x -> -3 xxxxxxxx
//   integer i1 = -7, i2, ia [0:1]               -> -7, i2 x: i2 === 32'bx -> 1
//   time tm = 5, ta [0:1]                       -> 5
//   real rr = 1.5, rx, ra [0:1]                 -> 1.5; rx unassigned, 0.0
//                                                  (§4.2.2)
//   realtime rt = 0.25, rtz                     -> 0.25 0.0
// The arrays are then written and read: rm[1] = 8'sd9, ia[0] = 3,
// ta[1] = 7, ra[0] = 4.5 -> 9 3 7 4.500000
//! inherited IEEE 1364-2005 6.2.2
// native-required
module b_6_2_2_declaration_forms;
  reg signed [7:0] rs = -8'sd3, ru, rm [0:1];
  integer i1 = -7, i2, ia [0:1];
  time tm = 5, ta [0:1];
  real rr = 1.5, rx, ra [0:1];
  realtime rt = 0.25, rtz;
  initial begin
    #1 $display("%0d %b", rs, ru);
    $display("%0d %b %0d", i1, i2 === 32'bx, tm);
    $display("%f %f %f %f", rr, rx, rt, rtz);
    rm[1] = 8'sd9; ia[0] = 3; ta[1] = 7; ra[0] = 4.5;
    $display("%0d %0d %0d %f", rm[1], ia[0], ta[1], ra[0]);
    $finish(0);
  end
endmodule
