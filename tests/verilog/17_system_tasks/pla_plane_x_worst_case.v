// IEEE 1364-2005 17.5.4, plane format: "x  Take the 'worst case' of the
// input value." and, separately, "z  Do-not-care; the input value is of no
// significance."  An x personality bit leaves open whether the term is the
// true input (1) or its complement (0). Those two differ for every input
// value, so the worst case of the term is x, whatever the input is. z, not
// x, is the ignore symbol. By hand, two inputs, rows x1, x0, xz:
//   AND, inputs 11: x&1 = x, x&~1 = x&0 = 0, x alone = x   -> x0x
//   AND, inputs 00: x&0 = 0, x&~0 = x&1 = x, x            -> 0xx
//   OR,  inputs 11: x|1 = 1, x|0 = x,         x            -> 1xx
// Reading x as "ignore" (the defect this pins) prints 101, 011 and 100: the
// all-ignored AND row is the constant 1 and the OR row the constant 0.
// No invalid form: every four-state bit has a 17.5.4 meaning.
// pla_plane_ignore.v is the z/? neighbour.
//! lrm 9.8
//! inherited IEEE 1364-2005 17.5.4
//! expect stdout pla_plane_x_worst_case.expected.txt
module audit_pla_plane_x_worst_case;
  reg [1:2] personality [1:3];
  reg [1:2] inputs;
  reg [1:3] outputs;
  initial begin
    personality[1] = 2'bx1;
    personality[2] = 2'bx0;
    personality[3] = 2'bxz;
    inputs = 2'b11;
    $sync$and$plane(personality, inputs, outputs);
    $display("and11=%b", outputs);
    inputs = 2'b00;
    $sync$and$plane(personality, inputs, outputs);
    $display("and00=%b", outputs);
    inputs = 2'b11;
    $sync$or$plane(personality, inputs, outputs);
    $display("or11=%b", outputs);
    $finish(0);
  end
endmodule
