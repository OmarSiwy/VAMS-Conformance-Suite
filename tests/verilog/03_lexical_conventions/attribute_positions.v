// IEEE 1364-2005 §3.8.2, p. 18: "The syntax for legal statements with
// attributes is shown in Syntax 3-4 through Syntax 3-9." Those boxes place
// { attribute_instance } before: a module declaration (3-4, p. 18); a port
// declaration (3-5); a module item, among them a continuous assign, a gate,
// a UDP and a module instantiation, initial, always, a parameter and a
// localparam (3-6, p. 19); a function input, a task port and a block item
// declaration (3-7; a function or task port is Annex A.2.6/A.2.7's
// tf_input_declaration, pp. 492-493, which admits `input integer`); an ordered and a named port connection (3-8, p. 20); a
// UDP declaration and its output and input declarations (3-9).
//
// §3.8 standardizes no attribute, so each position is accepted and the
// design computes as if it were absent:
//   a UDP inverter g drives nu = ~r; r = 0 -> nu = 1
//   the gate buf drives nb = r -> 0; assign drives na = r -> 0
//   the child copies r through ordered and named connections -> 0 0
//   P + L = 3 + 4 -> 7; f(5) returns its input -> 5;
//   task t copies its input 6 to its output through a block reg -> 6
//   always @(r) prints "always 0" when r changes from x to 0; r is set at
//   #1 so the always is already waiting (no time-0 race, §11.4)
// Printed: "always 0" at time 1, then at time 2 "1 0 0 0 0 7 5 6".
//! inherited IEEE 1364-2005 3.8.2
(* keep *) primitive b_3_8_2_inv ((* p *) output o, input a);
  table 0 : 1; 1 : 0; endtable
endprimitive
(* keep *) primitive b_3_8_2_inv2 (o, a);
  (* p *) output o;
  (* q *) input a;
  table 0 : 1; 1 : 0; endtable
endprimitive
(* keep *) module b_3_8_2_child ((* p *) input i, (* q *) output o);
  assign o = i;
endmodule
(* keep *) module b_3_8_2_attribute_positions;
  (* k *) reg r;
  (* k *) wire nu, nb, na, oo, on;
  (* k *) parameter P = 3;
  (* k *) localparam L = 4;
  integer ft, tt;
  (* k *) b_3_8_2_inv g (nu, r);
  (* k *) buf bb (nb, r);
  (* k *) assign na = r;
  (* k *) b_3_8_2_child c1 ((* k *) r, (* k *) oo);
  b_3_8_2_child c2 ((* k *) .i(r), (* k *) .o(on));
  function integer f ((* k *) input integer x);
    f = x;
  endfunction
  task t ((* k *) input integer x, (* k *) output integer y);
    (* k *) reg [7:0] tmp;
    begin
      tmp = x;
      y = tmp;
    end
  endtask
  (* k *) always @(r) $display("always %b", r);
  (* k *) initial begin
    #1 r = 0;
    ft = f(5);
    t(6, tt);
    #1 $display("%b %b %b %b %b %0d %0d %0d", nu, nb, na, oo, on, P + L, ft, tt);
    $finish(0);
  end
endmodule
