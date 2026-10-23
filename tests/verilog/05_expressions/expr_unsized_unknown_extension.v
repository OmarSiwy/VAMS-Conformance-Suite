// IEEE1364-2005 Table5-22 footnote: an unsized constant with top x/z
// extends that state into a context wider than32 bits. A sized unsigned
// 4'bx instead has only four x bits; assignment pads the remaining125 zero.
// Comparisons use independent explicit129-bit expected patterns.
//! inherited IEEE 1364-2005 5.4.1 5.5.3
module audit_expr_unsized_unknown_extension;
  reg [128:0] xwide, zwide, sized;
  initial begin
    xwide = 'hx;
    zwide = 'hz;
    sized = 4'bx;
    $display("unsized=%b,%b sized=%b", xwide === 129'bx, zwide === 129'bz,
             sized === {{125{1'b0}},4'bxxxx});
    $finish(0);
  end
endmodule
