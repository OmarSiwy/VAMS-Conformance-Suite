// IEEE 1364-2005 §12.4.3, p. 190: "Each generate construct in a given scope is
// assigned a number. The number will be 1 for the construct that appears
// textually first in that scope and will increase by 1 for each subsequent
// generate construct in that scope. All unnamed generate blocks will be given
// the name "genblk<n>" where <n> is the number assigned to its enclosing
// generate construct. If such a name would conflict with an explicitly
// declared name, then leading zeroes are added in front of the number until
// the name does not conflict." §12.4.2, p. 188, of its multiplier: "The
// hierarchical instance name is mult.u1". §12.5, p. 191: "each module
// instance ..., generate block instance, task definition, function definition,
// and named begin-end or fork-join block shall define a new branch of the
// hierarchy." §17.1.1.6, p. 285: %m prints "the hierarchical name of the module,
// task, function, or named block that invokes the system task".
//
// Scope top (this module), parameter genblk2 declared, as in the clause's
// example:
//   construct 1, unnamed: genblk1; its named block nb1 -> top.genblk1.nb1
//   construct 2, unnamed: genblk2 conflicts with the parameter -> genblk02;
//     its else branch runs (genblk2 = 0): nb2 -> top.genblk02.nb2
//   construct 3, named mult: the instance u1 in it -> top.mult.u1
//   construct 4, unnamed: genblk4 (number 4 although construct 3 was named)
//     -> top.genblk4.nb4
// with top = b_12_4_3_generate_scopes_in_names; each prints at its own time.
//! inherited IEEE 1364-2005 12.4.3 12.4.2 12.5
`timescale 1ns/1ns
module leaf;
  initial #3 $display("%m");
endmodule
module b_12_4_3_generate_scopes_in_names;
  parameter genblk2 = 0;
  if (1) begin
    initial begin : nb1 #1 $display("%m"); end
  end
  if (genblk2) begin
    initial begin : nb2a #2 $display("%m"); end
  end else begin
    initial begin : nb2 #2 $display("%m"); end
  end
  if (1) begin : mult
    leaf u1();
  end
  if (1) begin
    initial begin : nb4 #4 $display("%m"); end
  end
endmodule
