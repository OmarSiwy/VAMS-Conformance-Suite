// IEEE 1364-2005 Syntax 8-1, p. 106: "udp_output_declaration ::= ... output reg
// port_identifier [ = constant_expression ]", in both the header's
// udp_declaration_port_list and a udp_port_declaration. §8.1.2, p. 107:
// "Sequential UDPs shall contain a reg declaration for the output port ...
// or as part of the output_declaration. ... The initial value of the output
// port can be specified in an initial statement in a sequential UDP (see
// 8.1.3)." §8.1.3: the initial statement "specifies the value of the output
// port when simulation begins". The declaration's `= constant_expression` is
// the same assignment written on the output reg declaration, so it is read as
// the initial value (the reading IEEE 1800 §29.4 states for the same syntax).
//
// Both latches load d while g = 1 and hold while g = 0.
//   t=1  no input has changed: hdr (header form, = 1'b1) shows 1, body (port
//        declaration form, = 1'b0) shows 0 -> "10"
//   t=1  g = 0: `0 ? : ? : -` keeps each state            t=2: "10"
//   t=2  d = 1, g = 1: both load 1                         t=3: "11"
//! inherited IEEE 1364-2005 8.1.2 8.1.3
`timescale 1ns/1ns
primitive hdr(output reg q = 1'b1, input g, d);
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

primitive body(q, g, d);
  output reg q = 1'b0;
  input g, d;
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module b_8_1_3_output_reg_initializer;
  reg g, d;
  wire qh, qb;
  hdr uh(qh, g, d);
  body ub(qb, g, d);
  initial begin
    #1 $display("%b%b", qh, qb);
    g = 0;
    #1 $display("%b%b", qh, qb);
    d = 1;
    g = 1;
    #1 $display("%b%b", qh, qb);
    $finish(0);
  end
endmodule
