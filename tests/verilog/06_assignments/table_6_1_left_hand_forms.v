// IEEE 1364-2005 §6, p. 68: "The left-hand side can take one of the forms
// given in Table 6-1, depending on whether the assignment is a continuous
// assignment or a procedural assignment." Table 6-1, p. 68:
//   Continuous assignment: Net (vector or scalar); Constant bit-select of a
//   vector net; Constant part-select of a vector net; Constant indexed
//   part-select of a vector net; Concatenation or nested concatenation of any
//   of the above left-hand side.
//   Procedural assignment: Variables (vector or scalar); Bit-select of a
//   vector reg, integer, or time variable; Constant part-select of a vector
//   reg, integer, or time variable; Indexed part-select of a vector reg,
//   integer, or time variable; Memory word; Concatenation or nested
//   concatenation of any of the above left-hand side.
//
// The rows VerA runs. The net selects and every concatenation are pinned in
// table_6_1_select_and_concatenation_lhs.v (xfail), the indexed
// part-selects in indexed_part_select_lhs.v (xfail). Reads are at
// time 1, after every time-0 assignment.
// Continuous, a = 1, r8 = 8'hA5:
//   s = a                                  -> 1 (scalar net)
//   v = r8                                 -> 10100101 (vector net)
// Procedural:
//   sv = 1                                 -> 1 (scalar variable)
//   rv = 0; rv[7] = 1; rv[3:0] = 4'hC      -> 1000_1100 -> 8c (reg)
//   iv = 0; iv[31] = 1; iv[3:0] = 4'hF     -> 8000000f (integer, 32 bits)
//   tv = 0; tv[63] = 1; tv[7:4] = 4'hA     -> 80000000000000a0 (time, 64 bits)
//   mem[2] = 8'h3C                         -> 3c (memory word)
//! inherited IEEE 1364-2005 6
module b_6_table_6_1_left_hand_forms;
  reg a;
  reg [7:0] r8;
  wire s;
  wire [7:0] v;
  assign s = a;
  assign v = r8;

  reg sv;
  reg [7:0] rv;
  integer iv;
  time tv;
  reg [7:0] mem [0:3];
  initial begin
    a = 1;
    r8 = 8'hA5;
    sv = 1;
    rv = 0; rv[7] = 1; rv[3:0] = 4'hC;
    iv = 0; iv[31] = 1; iv[3:0] = 4'hF;
    tv = 0; tv[63] = 1; tv[7:4] = 4'hA;
    mem[2] = 8'h3C;
    #1;
    $display("%b %b", s, v);
    $display("%b %h %h %h %h", sv, rv, iv, tv, mem[2]);
    $finish(0);
  end
endmodule
