// IEEE 1364-2005 §9.5, p. 127: "The case expression given in parentheses shall
// be evaluated exactly once and before any of the case item expressions. The
// case item expressions shall be evaluated and compared in the exact order in
// which they are given. If there is a default case item, it is ignored during
// this linear search. During the linear search, if one of the case item
// expressions matches the case expression given in parentheses, then the
// statement associated with that case item shall be executed, and the linear
// search shall terminate. If all comparisons fail and the default item is
// given, then the default item statement shall be executed. If the default
// statement is not given and all of the comparisons fail, then none of the
// case item statements shall be executed."
// p. 128: "The length of all the case item expressions, as well as the case
// expression in the parentheses, shall be made equal to the length of the
// longest case expression and case item expression. If any of these
// expressions is unsigned, then all of them shall be treated as unsigned. If
// all of these expressions are signed, then they shall be treated as signed."
//
// t(id, v) appends id to `evals` (evals*10 + id) and returns v, so the digits
// of `evals` are the expressions evaluated, in order.
//   1: case (t(1,1)) t(2,0): t(3,1): t(4,1): -> the case expression first and
//      once, then items 2 and 3; 3 matches, 4 is never evaluated.
//      prints "item3", evals = 123
//   2: default written first, then t(2,0), t(3,2): the default is skipped
//      during the search, both items are compared, neither matches (case
//      expression t(1,1) = 1) -> "default", evals = 123
//   3: same without a default: no statement runs -> evals = 123
//   4: one item listing t(2,0), t(3,1), t(4,1): its expressions are compared
//      in order and the search stops at t(3,1) -> "list", evals = 123
//   5: 3'sb111 against 4'sb1111: all signed, so 3'sb111 sign-extends to 1111
//      -> "signed"
//   6: 3'sb111 against 4'b0111 (unsigned): everything is unsigned, 3'sb111
//      zero-extends to 0111 -> "unsigned" (the 4'b1111 item written first
//      does not match)
//! inherited IEEE 1364-2005 9.5
module b_9_5_case_linear_search;
  integer evals;

  function [1:0] t(input integer id, input [1:0] v);
    begin
      evals = evals * 10 + id;
      t = v;
    end
  endfunction

  initial begin
    evals = 0;
    case (t(1, 2'd1))
      t(2, 2'd0): $display("BAD item2");
      t(3, 2'd1): $display("item3");
      t(4, 2'd1): $display("BAD item4");
    endcase
    $display("%0d", evals);
    evals = 0;
    case (t(1, 2'd1))
      default: $display("default");
      t(2, 2'd0): $display("BAD item2");
      t(3, 2'd2): $display("BAD item3");
    endcase
    $display("%0d", evals);
    evals = 0;
    case (t(1, 2'd1))
      t(2, 2'd0): $display("BAD item2");
      t(3, 2'd2): $display("BAD item3");
    endcase
    $display("%0d", evals);
    evals = 0;
    case (t(1, 2'd1))
      t(2, 2'd0), t(3, 2'd1), t(4, 2'd1): $display("list");
    endcase
    $display("%0d", evals);
    case (3'sb111)
      4'sb0111: $display("BAD zero-extended");
      4'sb1111: $display("signed");
    endcase
    case (3'sb111)
      4'b1111: $display("BAD sign-extended");
      4'b0111: $display("unsigned");
    endcase
    $finish(0);
  end
endmodule
