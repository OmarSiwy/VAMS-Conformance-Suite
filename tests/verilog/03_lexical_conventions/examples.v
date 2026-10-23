// IEEE 1364-2005 §3.8, p. 16: "An attribute_instance can appear in the
// Verilog description as a prefix attached to a declaration, a module item,
// a statement, or a port connection. It can appear as a suffix to an
// operator or a Verilog function name in an expression. If a value is not
// specifically assigned to the attribute, then its value shall be 1. If the
// same attribute name is defined more than once for the same language
// element, the last attribute value shall be used; and a tool can give a
// warning that a duplicate attribute specification has occurred."
// §3.8.1, pp. 16-18, gives eight examples; §1.8, p. 5: "These examples are
// informative."
//
// Every §3.8.1 example is below: Example 1's three case forms, Example 2's
// two, Example 3's module attribute (optimize_power), Example 4's
// instantiation attribute, Example 5's reg declarations, Example 6's operator
// suffix, Example 7's function-name suffix, Example 8's conditional-operator
// suffix; and a duplicate name (x twice). §3.8 standardizes no attribute, so
// none changes what the design computes:
//   foo = 1 selects the `1:` arm of each of the five cases -> "one" x5
//   state1 = 1 -> 1
//   a = b + c = 1 + 2 -> 3; a = add(b, c) -> 3; a = b ? c : d -> 2
//   the instance mod1 copies its input 1 to its output -> 1 (after #1)
//! inherited IEEE 1364-2005 3.8 3.8.1
(* optimize_power *)
module b_3_8_1_examples;
  reg [1:0] foo;
  (* fsm_state *) reg [7:0] state1;
  (* fsm_state=1 *) reg [3:0] state2, state3;
  reg [3:0] reg1; // this reg does NOT have fsm_state set
  (* fsm_state=0 *) reg [3:0] reg2; // nor does this one
  reg [3:0] a, b, c, d;
  reg in;
  wire out;
  (* optimize_power=0 *)
  b_3_8_1_mod1 synth1 (out, in);
  function [3:0] add(input [3:0] x, input [3:0] y);
    add = x + y;
  endfunction
  initial begin
    foo = 1;
    (* full_case, parallel_case *)
    case (foo) 1: $display("one"); default: $display("other"); endcase
    (* full_case=1 *)
    (* parallel_case=1 *) // Multiple attribute instances also OK
    case (foo) 1: $display("one"); default: $display("other"); endcase
    (* full_case, // no value assigned
       parallel_case=1 *)
    case (foo) 1: $display("one"); default: $display("other"); endcase
    (* full_case *) // parallel_case not specified
    case (foo) 1: $display("one"); default: $display("other"); endcase
    (* full_case=1, parallel_case = 0, full_case = 0 *)
    case (foo) 1: $display("one"); default: $display("other"); endcase
    state1 = 1;
    $display("%0d", state1);
    b = 1; c = 2; d = 3;
    a = b + (* mode = "cla" *) c;
    $display("%0d", a);
    a = add (* mode = "cla" *) (b, c);
    $display("%0d", a);
    a = b ? (* no_glitch *) c : d;
    $display("%0d", a);
    in = 1;
    #1 $display("%b", out);
    $finish(0);
  end
endmodule
(* optimize_power=1 *)
module b_3_8_1_mod1 (output o, input i);
  assign o = i;
endmodule
