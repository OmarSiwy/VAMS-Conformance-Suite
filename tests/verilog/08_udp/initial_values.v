// IEEE 1364-2005 §8.1.3, p. 107: "The sequential UDP initial statement
// specifies the value of the output port when simulation begins. This
// statement begins with the keyword initial. The statement that follows
// shall be an assignment statement that assigns a single-bit literal value
// to the output port."
// §8.5, p. 112: "When simulation starts, this value is the current state in
// the state table."
// Syntax 8-1, p. 106: "init_val ::= 1'b0 | 1'b1 | 1'bx | 1'bX | 1'B0 | 1'B1 |
// 1'Bx | 1'BX | 1 | 0"
//
// One latch per init_val, in the grammar's order: i0 = 1'b0, i1 = 1'b1,
// i2 = 1'bx, i3 = 1'bX, i4 = 1'B0, i5 = 1'B1, i6 = 1'Bx, i7 = 1'BX, i8 = 1,
// i9 = 0. Every table is g=1 loads d, g=0 holds (`-`).
//   t=1  no input has changed, so each output is its initial value:
//        "01xx01xx10"
//   t=1  g: x -> 0 matches `0 ? : ? : -`, which keeps the current state,
//        i.e. the initial value                   t=2: "01xx01xx10"
//   t=2  d: x -> 1 with g = 0, again `-`           t=3: "01xx01xx10"
//   t=3  g = 1 with d = 1 -> every latch loads 1   t=4: "1111111111"
//! inherited IEEE 1364-2005 8.1.3 8.5
`timescale 1ns/1ns
primitive i0(q, g, d);
  output q;
  reg q;
  input g, d;
  initial q = 1'b0;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

primitive i1(q, g, d);
  output q;
  reg q;
  input g, d;
  initial q = 1'b1;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

primitive i2(q, g, d);
  output q;
  reg q;
  input g, d;
  initial q = 1'bx;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

primitive i3(q, g, d);
  output q;
  reg q;
  input g, d;
  initial q = 1'bX;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

primitive i4(q, g, d);
  output q;
  reg q;
  input g, d;
  initial q = 1'B0;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

primitive i5(q, g, d);
  output q;
  reg q;
  input g, d;
  initial q = 1'B1;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

primitive i6(q, g, d);
  output q;
  reg q;
  input g, d;
  initial q = 1'Bx;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

primitive i7(q, g, d);
  output q;
  reg q;
  input g, d;
  initial q = 1'BX;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

primitive i8(q, g, d);
  output q;
  reg q;
  input g, d;
  initial q = 1;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

primitive i9(q, g, d);
  output q;
  reg q;
  input g, d;
  initial q = 0;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module b_8_1_3_initial_values;
  reg g, d;
  wire q0, q1, q2, q3, q4, q5, q6, q7, q8, q9;
  i0 u0(q0, g, d);
  i1 u1(q1, g, d);
  i2 u2(q2, g, d);
  i3 u3(q3, g, d);
  i4 u4(q4, g, d);
  i5 u5(q5, g, d);
  i6 u6(q6, g, d);
  i7 u7(q7, g, d);
  i8 u8(q8, g, d);
  i9 u9(q9, g, d);
  initial begin
    #1 $display("%b%b%b%b%b%b%b%b%b%b", q0, q1, q2, q3, q4, q5, q6, q7, q8, q9);
    g = 0;
    #1 $display("%b%b%b%b%b%b%b%b%b%b", q0, q1, q2, q3, q4, q5, q6, q7, q8, q9);
    d = 1;
    #1 $display("%b%b%b%b%b%b%b%b%b%b", q0, q1, q2, q3, q4, q5, q6, q7, q8, q9);
    g = 1;
    #1 $display("%b%b%b%b%b%b%b%b%b%b", q0, q1, q2, q3, q4, q5, q6, q7, q8, q9);
    $finish(0);
  end
endmodule
