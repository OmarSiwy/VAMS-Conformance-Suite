// IEEE 1364-2005 §8.1.6, p. 108, Table 8-1 (UDP table symbols):
//   "? Iteration of 0, 1, and x"; "b Iteration of 0 and 1";
//   "- No change"; "(vw) Value change from v to w ... v and w can be any one
//   of 0, 1, x, ?, or b, and are only permitted in the input field";
//   "* Same as (??) Any value change on input"; "r Same as (01) Rising edge
//   on input"; "f Same as (10) Falling edge on input"; "p Iteration of (01),
//   (0 x) and (x1) Potential positive edge on the input"; "n Iteration of
//   (10), (1x)and (x0 Potential negative edge on the input."
// §8.4, p. 110: "All unspecified transitions default to the output value x."
//
// Four sequential UDPs on one input c, each with `initial q = 0`:
//   pn:   p -> 1, n -> 0. Every change of a scalar input is in p or n.
//   rf:   r -> 1, f -> 0, and (0x) (x1) (1x) (x0) -> - (no change).
//   star: * with current state 0 -> 1, * with current state 1 -> 0: toggles
//         on every change.
//   vw:   (bx) = (0x),(1x) -> 1; (xb) = (x0),(x1) -> 0; (01), (10) -> -.
// c steps x -> 0 -> 1 -> x -> 0 -> x -> 1 -> 0:
//   change  pn        rf        star      vw
//   (x0)    n  -> 0   -  -> 0   * -> 1    (xb) -> 0
//   (01)    p  -> 1   r  -> 1   * -> 0    -    -> 0
//   (1x)    n  -> 0   -  -> 1   * -> 1    (bx) -> 1
//   (x0)    n  -> 0   -  -> 1   * -> 0    (xb) -> 0
//   (0x)    p  -> 1   -  -> 1   * -> 1    (bx) -> 1
//   (x1)    p  -> 1   -  -> 1   * -> 0    (xb) -> 0
//   (10)    n  -> 0   f  -> 0   * -> 1    -    -> 0
// Two combinational UDPs:
//   bl(y, a): the one row `b : 1`. a = 0 or 1 -> 1; a = x matches no row -> x.
//   ql(y, a, s): `? 1 : 1`, `? 0 : 0`, `x x : x`. With s = 1, a = x still
//   matches `?` -> 1; with s = x and a = 0 no row matches -> x.
//   a=0 (s=x): bl 1, ql x;  s=1: 1 1;  a=1: 1 1;  a=x: bl x, ql 1;
//   s=0: bl x, ql 0.
//! inherited IEEE 1364-2005 8.1.6
`timescale 1ns/1ns
primitive pn(q, c);
  output q;
  reg q;
  input c;
  initial q = 0;
  table
    p : ? : 1;
    n : ? : 0;
  endtable
endprimitive

primitive rf(q, c);
  output q;
  reg q;
  input c;
  initial q = 0;
  table
    r    : ? : 1;
    f    : ? : 0;
    (0x) : ? : -;
    (x1) : ? : -;
    (1x) : ? : -;
    (x0) : ? : -;
  endtable
endprimitive

primitive star(q, c);
  output q;
  reg q;
  input c;
  initial q = 0;
  table
    * : 0 : 1;
    * : 1 : 0;
  endtable
endprimitive

primitive vw(q, c);
  output q;
  reg q;
  input c;
  initial q = 0;
  table
    (bx) : ? : 1;
    (xb) : ? : 0;
    (01) : ? : -;
    (10) : ? : -;
  endtable
endprimitive

primitive bl(y, a);
  output y;
  input a;
  table
    b : 1;
  endtable
endprimitive

primitive ql(y, a, s);
  output y;
  input a, s;
  table
    ? 1 : 1;
    ? 0 : 0;
    x x : x;
  endtable
endprimitive

module b_8_1_6_table_symbols;
  reg c, a, s;
  wire q1, q2, q3, q4, y1, y2;
  pn u1(q1, c);
  rf u2(q2, c);
  star u3(q3, c);
  vw u4(q4, c);
  bl u5(y1, a);
  ql u6(y2, a, s);
  initial begin
    c = 0;
    #1 $display("x0 %b %b %b %b", q1, q2, q3, q4);
    c = 1;
    #1 $display("01 %b %b %b %b", q1, q2, q3, q4);
    c = 1'bx;
    #1 $display("1x %b %b %b %b", q1, q2, q3, q4);
    c = 0;
    #1 $display("x0 %b %b %b %b", q1, q2, q3, q4);
    c = 1'bx;
    #1 $display("0x %b %b %b %b", q1, q2, q3, q4);
    c = 1;
    #1 $display("x1 %b %b %b %b", q1, q2, q3, q4);
    c = 0;
    #1 $display("10 %b %b %b %b", q1, q2, q3, q4);
    a = 0;
    #1 $display("a0 %b %b", y1, y2);
    s = 1;
    #1 $display("s1 %b %b", y1, y2);
    a = 1;
    #1 $display("a1 %b %b", y1, y2);
    a = 1'bx;
    #1 $display("ax %b %b", y1, y2);
    s = 0;
    #1 $display("s0 %b %b", y1, y2);
    $finish(0);
  end
endmodule
