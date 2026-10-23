// IEEE 1364-2005 §3.8 / AMS §2.9: prefixes belong to their parsed
// declarations/statements/connections; suffixes belong to operators/calls.
// attributes.c checks both the metadata and the executed values.
`define ATTRIBUTE_NET (* net_attr = "on" *)
(* mod_attr = 1, defaulted, duplicate = 3, duplicate = 4 *)
(* duplicate = 9 *)
module b26_attributes;
  parameter BASE = 10;
  `ATTRIBUTE_NET wire w, w2;
  wire plain;
  reg r;
  (* reg_attr *) reg tagged;
  (* kind_attr = 3, wide_attr = 80'h123456789abcdef0xz12, real_attr = 1.25 *)
  integer marked;
  (* event_attr *) event e, e2;

  (* instance_attr = BASE + 1 *) attr_child #(3) a((* conn_attr = BASE *) .i(r));
  (* instance_attr = BASE + 2 *) attr_child #(5) b((* conn_attr = BASE + 1 *) .i(r));
  (* pair_attr = BASE *) attr_child c(r), d(r);
  genvar g;
  generate for (g = 0; g < 2; g = g + 1) begin : generated
    (* index_attr = g + 5 *) wire gw;
    assign gw = r;
  end endgenerate

  (* assign_attr *) assign w = r, w2 = r;
  assign plain = r;
  (* function_attr = BASE *) function integer f;
    localparam BASE = 20;
    (* formal_attr = BASE *) input integer x;
    (* local_attr = BASE *) integer tmp;
    begin tmp = x + 1; f = tmp; end
  endfunction

  (* process_attr *) initial begin
    r = 0;
    (* statement_attr *) marked = 1 + (* operation_attr = "sum" *) 2;
    marked = - (* unary_attr *) marked;
    marked = r ? (* conditional_attr *) 7 : 8;
    marked = f (* call_attr *) (marked);
    r = 1;
    #1 $finish(0);
  end
endmodule

(* child_attr = 7 *)
module attr_child #(parameter W = 2) ((* port_attr = W *) input i);
  (* internal_attr = W * 2 *) wire localw;
  (* constant_call = twice(W) *) integer tagged;
  function integer twice;
    input integer n;
    begin twice = n * 2; end
  endfunction
  assign localw = i;
endmodule
