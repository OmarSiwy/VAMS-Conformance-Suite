// IEEE 1364-2005 A.9.1, p. 507:
//   attribute_instance ::= (* attr_spec { , attr_spec } *)
//   attr_spec ::= attr_name [ = constant_expression ]
//   attr_name ::= identifier
//
// Attribute instances where A.1.2, A.1.4, A.2.8, A.4.1, A.6.4 and A.8.3 allow
// them: on a module declaration, on a module item, on a block item
// declaration, on a port connection, on a statement and on an operator, with
// attr_specs with and without a value and a list of two. §3.8, p. 16 (quoted
// for context): "An attribute_instance can appear in the Verilog description
// as a prefix attached to a declaration, a module item, a statement, or a port
// connection. It can appear as a suffix to an operator or a Verilog function
// name in an expression." VerA names none of these attributes, so none
// changes a value: a = 2, b = 1 + 2 = 3, c = a + b = 5 through the child.
// Output: "c=5".
//! inherited IEEE 1364-2005 A.9.1
(* top_mark *)
module b_A_9_1_attributes;
  (* keep = 1, note = "w" *) wire [3:0] c;
  reg [3:0] a, b;
  b_A_9_1_add u ((* conn *) .x(a), .y(b), .s(c));
  initial begin : blk
    (* ctr *) integer k;
    (* step = 2 *) a = 4'd2;
    b = 4'd1 + (* op *) 4'd2;
    k = 0;
    #1 $display("c=%0d", c);
    $finish(0);
  end
endmodule
module b_A_9_1_add (x, y, s);
  input [3:0] x, y;
  output [3:0] s;
  assign s = x + y;
endmodule
