// IEEE1364-2005 §5.1.9: truth is not bitwise identity; a known1 makes
// a mixed vector true. Controlling0 for&& and1 for|| resolve ambiguity.
//! inherited IEEE 1364-2005 5.1.9
module audit_expr_logical_unknowns;
  initial begin
    $display("not=%b,%b,%b",!4'b0000,!4'b1xzz,!4'b0xzz);
    $display("and=%b,%b,%b",1'b0&&1'bx,1'b1&&1'bz,4'b1xxx&&4'b0010);
    $display("or=%b,%b,%b",1'b1||1'bz,1'b0||1'bx,4'b0000||4'b0100);
    $finish(0);
  end
endmodule
