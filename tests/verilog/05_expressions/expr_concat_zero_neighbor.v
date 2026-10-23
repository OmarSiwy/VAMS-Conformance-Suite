// IEEE1364-2005 §5.1.14: zero replication contributes no bits when an
// immediate concatenation sibling has positive width. Sizeda+5 givesa5.
//! inherited IEEE 1364-2005 5.1.14
module audit_expr_concat_zero_neighbor;
  reg [7:0] value;
  initial begin
    value={4'ha,{0{1'b1}},4'h5};
    $display("concat=%h",value);
    $finish(0);
  end
endmodule
