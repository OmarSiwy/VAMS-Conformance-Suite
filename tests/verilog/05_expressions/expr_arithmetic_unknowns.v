// IEEE1364-2005 §§5.1.5/5.1.7: signed division truncates toward0,
// remainder follows dividend. Divide/modulo by0 and arithmeticx/z yieldallx;
// any relationalx/z operand produces1-bitx even if known bits differ.
//! inherited IEEE 1364-2005 5.1.5 5.1.7
module audit_expr_arithmetic_unknowns;
  reg signed [7:0] a,b,q,r;
  reg [7:0] divzero,modzero,unknown_sum;
  initial begin
    a=-8'sd10; b=8'sd3; q=a/b; r=a%b;
    $display("signed=%0d,%0d",q,r);
    a=8'sd11; b=-8'sd3; q=a/b; r=a%b;
    $display("negative_divisor=%0d,%0d",q,r);
    divzero=8'd5/8'd0; modzero=8'd5%8'd0;
    unknown_sum=8'b0000000z+8'd1;
    $display("unknown=%b,%b,%b relation=%b",divzero,modzero,unknown_sum,4'b1x00>4'b0000);
    $finish(0);
  end
endmodule
