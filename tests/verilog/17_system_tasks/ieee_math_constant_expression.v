// IEEE1364-2005 17.11 permits math system functions in constant expressions.
// 2^3<9<=2^4, so the packed declaration must elaborate to4bits,
// and clog2(8)=3 means a replication of3 one-bits. These observe elaboration,
// not only a runtime call whose constant operands happen to be folded.
//! lrm 9.14
//! inherited IEEE 1364-2005 17.11
module audit_ieee_math_constant_expression;
  reg [$clog2(9)-1:0] bits;
  initial begin
    bits = { $clog2(8) {1'b1} };
    $display("constant %b", bits);
    $finish(0);
  end
endmodule
