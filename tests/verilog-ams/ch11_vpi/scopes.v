// p04_11's design: one leaf definition instantiated three times, each
// instance holding its own parameter value in `r`. The top declares a task
// and a loop generate BEFORE its plain child, so the engine has minted a task
// frame and two generate iterations ahead of `c` — scopes that are not
// instances and that the object model must not count as instances.
module p04_leaf_s #(parameter V = 0);
  reg [7:0] r;
  initial r = V;
endmodule

module p04_scopes;
  task t; begin end endtask
  genvar i;
  generate for (i = 0; i < 2; i = i + 1) begin : g
    p04_leaf_s #(i + 1) u();
  end endgenerate
  p04_leaf_s #(8'h11) c();
  initial t;
endmodule
