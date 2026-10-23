// IEEE 1364-2005 §12.8.2, p. 198: "It shall be an error if a hierarchical name
// in a defparam is resolved before the hierarchy is completely elaborated and
// that name would resolve differently once the model is completely
// elaborated." The clause's example (pp. 197-198) is the design below: "the
// defparam must be evaluated before the conditional generate is elaborated.
// At this point in elaboration, the name resolves to parameter p in module
// mid1 ... After the hierarchy below the generate construct is elaborated, the
// rules for hierarchical name resolution would dictate that the name should
// have resolved to parameter p in module mid2."
//
// Legal neighbour: defparam_before_generate.v (a defparam whose
// target no generate block can shadow).
//! inherited IEEE 1364-2005 12.8.2
//! reject E1100
//! reject would resolve differently
//! neighbour defparam_before_generate.v
module m;
  m1 n();
endmodule
module m1;
  parameter p = 2;
  defparam m.n.p = 1;
  initial $display(m.n.p);
  generate
    if (p == 1) begin : m
      m2 n();
    end
  endgenerate
endmodule
module m2;
  parameter p = 3;
endmodule
