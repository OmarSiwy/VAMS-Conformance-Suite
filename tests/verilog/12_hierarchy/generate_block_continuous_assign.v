// Verilog-AMS §6.6: a generate block may hold every module item except
// ports, parameters, specify blocks and specparams; A.1.4
// module_or_generate_item lists continuous_assign (A.6.1). IEEE 1364-2005
// 12.4.2: "The selected generate block, if any, is instantiated into the
// model." With `if (1)` the block is selected, so the assignment below exists
// and drives `y` from `a`.
//
// The `else` arm is not selected, so its assignment does not exist; were it
// instantiated as well, y would have two opposing drivers and read x.
//
// HAND DERIVATION: t=0 a<-1, so `assign y = a` drives y to 1; at t=1 the
// display reads y = 1.
//
//! inherited IEEE 1364-2005 12.4.2
`timescale 1ns/1ns
module audit_generate_block_continuous_assign;
  wire y;
  reg a;
  generate
    if (1) begin : g
      assign y = a;
    end else begin : h
      assign y = ~a;
    end
  endgenerate
  initial begin a = 1; #1 $display("%b", y); $finish(0); end
endmodule
