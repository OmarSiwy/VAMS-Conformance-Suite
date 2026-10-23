// IEEE 1364-2005 §4.5, p. 25: "The syntax shown in 4.2 shall be used to
// declare nets and variables explicitly. In the absence of an explicit
// declaration, an implicit net of default net type shall be assumed in the
// following circumstances:" — a port expression declaration, the terminal
// list of a primitive or module instance, and the left-hand side of a
// continuous assignment. No other use of an undeclared name declares one.
//
// undeclared_r is the target of a procedural assignment, none of the three
// circumstances, so it is an undeclared identifier (and a procedural
// assignment could not target a net anyway, §9.2). Legal neighbour:
// implicit_nets.v's continuous-assignment target k.
//! inherited IEEE 1364-2005 4.5
//! reject E1100
//! reject undeclared digital variable
//! neighbour implicit_nets.v
module b_4_5_undeclared_procedural_target_rejected;
  initial begin
    undeclared_r = 1;
    $display("%b", undeclared_r);
  end
endmodule
