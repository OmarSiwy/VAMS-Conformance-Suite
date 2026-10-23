// IEEE 1364-2005 §9.4, p. 125: "If the expression evaluates to true (that is,
// has a nonzero known value), the first statement shall be executed. If it
// evaluates to false (that is, has a zero value or the value is x or z), the
// first statement shall not execute. If there is an else statement and
// expression is false, the else statement shall be executed." ... "This is
// resolved by always associating the else with the closest previous if that
// lacks an else." ... "If that association is not desired, a begin-end block
// statement shall be used to force the proper association".
//
//   if (4'b0100)  nonzero known            -> "then"
//   if (4'b0000)                           -> "else"
//   if (1'bx), if (1'bz)                   -> false -> "else-x", "else-z"
//   The clause's pair, index = 0, rega = 1, regb = 2:
//     if (index > 0) if (rega > regb) result = rega; else result = regb;
//       the else binds to the inner if; the outer if is false, so nothing
//       runs and result keeps 9
//     if (index > 0) begin if (rega > regb) result = rega; end
//     else result = regb;
//       the else binds to the outer if -> result = regb = 2
//! inherited IEEE 1364-2005 9.4
module b_9_4_if_truth_and_else_binding;
  integer index, rega, regb, result;

  initial begin
    if (4'b0100) $display("then"); else $display("BAD");
    if (4'b0000) $display("BAD"); else $display("else");
    if (1'bx) $display("BAD"); else $display("else-x");
    if (1'bz) $display("BAD"); else $display("else-z");
    index = 0;
    rega = 1;
    regb = 2;
    result = 9;
    if (index > 0)
      if (rega > regb)
        result = rega;
      else
        result = regb;
    $display("%0d", result);
    if (index > 0) begin
      if (rega > regb)
        result = rega;
    end
    else result = regb;
    $display("%0d", result);
    $finish(0);
  end
endmodule
