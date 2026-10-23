// IEEE 1364-2005 §9.4.1, p. 126: "The expressions shall be evaluated in
// order. If any expression is true, the statement associated with it shall be
// executed, and this shall terminate the whole chain." ... "The last else part
// of the if-else-if construct handles the none-of-the-above or default case
// where none of the other conditions were satisfied. Sometimes there is no
// explicit action for the default. In that case, the trailing else statement
// can be omitted".
//
// t(id, v) appends its id to `evals` (evals*10 + id) and returns v, so the
// digits of `evals` are the conditions evaluated, in order.
//   chain 1: t(1,0) false, t(2,1) true -> "second"; t(3,..) never evaluated
//            -> evals = 12
//   chain 2: t(1,0), t(2,0), t(3,0) all false -> trailing else "default"
//            -> evals = 123
//   chain 3: no trailing else; t(1,0) false, t(2,x) is x, which §9.4 counts as
//            false -> nothing executes -> evals = 12
//! inherited IEEE 1364-2005 9.4.1
module b_9_4_1_if_else_if_chain;
  integer evals;

  function t(input integer id, input v);
    begin
      evals = evals * 10 + id;
      t = v;
    end
  endfunction

  initial begin
    evals = 0;
    if (t(1, 1'b0)) $display("BAD first");
    else if (t(2, 1'b1)) $display("second");
    else if (t(3, 1'b1)) $display("BAD third");
    else $display("BAD default");
    $display("%0d", evals);
    evals = 0;
    if (t(1, 1'b0)) $display("BAD first");
    else if (t(2, 1'b0)) $display("BAD second");
    else if (t(3, 1'b0)) $display("BAD third");
    else $display("default");
    $display("%0d", evals);
    evals = 0;
    if (t(1, 1'b0)) $display("BAD first");
    else if (t(2, 1'bx)) $display("BAD second");
    $display("%0d", evals);
    $finish(0);
  end
endmodule
