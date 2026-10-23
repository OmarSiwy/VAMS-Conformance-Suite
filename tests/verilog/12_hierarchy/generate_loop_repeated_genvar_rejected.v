// IEEE 1364-2005 §12.4.1: "It shall be an error if a genvar value is repeated
// during the evaluation of the loop generate scheme." The iteration `i = i`
// leaves i at 0, so the second evaluation of the scheme sees 0 again.
//! lrm 6.6.1
//! lrm 6.6.1:7
//! inherited IEEE 1364-2005 12.4.1
//! reject a genvar value is repeated
`timescale 1ns/1ns
module leaf; initial $display("leaf"); endmodule
module top;
  genvar i;
  generate
    for (i = 0; i < 2; i = i) begin : g
      leaf u();
    end
  endgenerate
endmodule
