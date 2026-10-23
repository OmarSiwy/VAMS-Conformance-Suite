// IEEE 1364-2005 §6.1.1, p. 69: "NOTE—Because a net can be declared only
// once, only one net declaration assignment can be made for a particular
// net. This contrasts with the continuous assignment statement; one net can
// receive multiple assignments of the continuous assignment form." The rule
// the note rests on is §4.2.1, p. 21: "It is illegal to redeclare a name
// already declared by a net, parameter, or variable declaration (see 4.11)."
//
// w carries two net declaration assignments, so its second declaration
// redeclares it. Legal neighbour: select_bus.v gives the net data
// four assignments of the continuous assignment form, and its busout one
// net declaration assignment.
//! inherited IEEE 1364-2005 6.1.1
//! reject E1100
//! reject duplicate digital variable
//! neighbour select_bus.v
module b_6_1_1_net_declared_twice_rejected;
  reg a, b;
  wire w = a;
  wire w = b;
  initial begin
    a = 1'b1;
    b = 1'b1;
    #1 $display("%b", w);
  end
endmodule
