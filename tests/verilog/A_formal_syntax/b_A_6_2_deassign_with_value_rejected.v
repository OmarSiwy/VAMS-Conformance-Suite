// IEEE 1364-2005 A.6.2, p. 497:
//   procedural_continuous_assignments ::= assign variable_assignment
//     | deassign variable_lvalue | ...
// deassign takes an lvalue alone; only assign and force take a
// variable_assignment with `= expression`.
//
// `deassign r = 4'd1;` gives deassign a right-hand side. Legal neighbour:
// b_A_6_2_procedural_assignments.v (`deassign r;`).
//! inherited IEEE 1364-2005 A.6.2
//! reject E0207
//! reject unexpected token: found `=`
//! neighbour b_A_6_2_procedural_assignments.v
module b_A_6_2_deassign_with_value_rejected;
  reg [3:0] r;
  initial begin
    assign r = 4'd9;
    deassign r = 4'd1;
    $display("unreachable");
  end
endmodule
