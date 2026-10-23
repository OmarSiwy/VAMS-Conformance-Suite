// IEEE1364-2005 §5.3: min:typ:max is allowed wherever expressions occur,
// and compound expressions use corresponding members. No chosen toolcorner
// is assumed: results must be13,22 or31, not necessarilythemiddle value.
// §7.14.1 permits unordered component triples;3:2:1 is not invalid.
//! inherited IEEE 1364-2005 5.3 7.14.1
module audit_expr_mintypmax_context;
  reg [7:0] value;
  initial begin
    value=(8'd1:8'd2:8'd3)*8'd10+(8'd3:8'd2:8'd1);
    $display("allowed=%b",(value===8'd13)||(value===8'd22)||(value===8'd31));
    $finish(0);
  end
endmodule
