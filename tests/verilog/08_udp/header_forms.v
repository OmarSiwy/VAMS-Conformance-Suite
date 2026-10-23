// IEEE 1364-2005 §8.1.1, p. 107: "A UDP definition shall have one of two
// alternate forms. The first form shall begin with the keyword primitive,
// followed by an identifier, which shall be the name of the UDP. This in turn
// shall be followed by a comma-separated list of port names enclosed in
// parentheses, which shall be followed by a semicolon. The UDP definition
// header shall be followed by port declarations and a state table." ... "The
// second form shall begin with the keyword primitive, followed by an
// identifier, which shall be the name of the UDP. This in turn shall be
// followed by a comma-separated list of port declarations enclosed in
// parentheses, followed by a semicolon. The UDP definition header shall be
// followed by a state table." ... "The output port shall be the first port in
// the port list."
// §8.1.2, p. 107: "Sequential UDPs shall contain a reg declaration for the
// output port, either in addition to the output declaration, when the UDP is
// declared using the first form of a UDP Header, or as part of the
// output_declaration."
// §8, p. 105: "Each UDP has exactly one output, which can be in one of three
// states: 0, 1, or x."
//
// and_a/and_b: the same AND table in the first and the second form.
// latch_a/latch_b: the same level-sensitive latch (g=1 loads d, g=0 holds),
// first form with `reg q;` beside `output q;`, second form with
// `output reg q` in the port list. Neither latch has an initial statement,
// so its state starts x (§8.5: the initial statement is optional).
//   t=1  nothing driven yet: every input x, no input has changed, so no
//        output has been evaluated -> "x x x x"
//   t=1  a=1, b=1 -> and: 1 1 -> 1.  g=0 -> latch row `0 ? : ? : -` keeps x;
//        d=0 with g=0 -> keeps x.            t=2: "1 1 x x"
//   t=2  b=0 -> and: 1 0 -> 0.  g=1 with d=0 -> row `1 0 : ? : 0` -> 0.
//                                            t=3: "0 0 0 0"
//   t=3  d=1 with g=1 -> 1.                  t=4: "0 0 1 1"
//   t=4  g=0 -> hold 1; then d=0 with g=0 -> hold 1.
//                                            t=5: "0 0 1 1"
//! inherited IEEE 1364-2005 8 8.1.1 8.1.2
`timescale 1ns/1ns
primitive and_a(y, a, b);
  output y;
  input a, b;
  table
    0 ? : 0;
    ? 0 : 0;
    1 1 : 1;
  endtable
endprimitive

primitive and_b(output y, input a, b);
  table
    0 ? : 0;
    ? 0 : 0;
    1 1 : 1;
  endtable
endprimitive

primitive latch_a(q, g, d);
  output q;
  reg q;
  input g, d;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

primitive latch_b(output reg q, input g, d);
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module b_8_1_1_header_forms;
  reg a, b, g, d;
  wire ya, yb, qa, qb;
  and_a u1(ya, a, b);
  and_b u2(yb, a, b);
  latch_a u3(qa, g, d);
  latch_b u4(qb, g, d);
  initial begin
    #1 $display("%b %b %b %b", ya, yb, qa, qb);
    a = 1;
    b = 1;
    g = 0;
    d = 0;
    #1 $display("%b %b %b %b", ya, yb, qa, qb);
    b = 0;
    g = 1;
    #1 $display("%b %b %b %b", ya, yb, qa, qb);
    d = 1;
    #1 $display("%b %b %b %b", ya, yb, qa, qb);
    g = 0;
    d = 0;
    #1 $display("%b %b %b %b", ya, yb, qa, qb);
    $finish(0);
  end
endmodule
