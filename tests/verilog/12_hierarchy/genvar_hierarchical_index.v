//! inherited IEEE 1364-2005 12.4.1 A.9.3
// Inside its loop generate block a genvar is constant, so target[i].val is a
// constant hierarchical index (pr1691599b).
module triage_genvar_hierarchical_index;
  parameter cnt = 4;
  genvar i;

  generate
    for (i = 0; i < cnt; i = i + 1) begin : target
      reg [1:0] val;
    end
  endgenerate

  initial begin
    target[0].val = 0;
    target[1].val = 1;
    target[2].val = 2;
    target[3].val = 3;
  end

  generate
    for (i = 0; i < cnt; i = i + 1) begin : sink
      wire [1:0] val = target[i].val;
      initial #1 if (val !== i) begin
        $display("FAILED sink[%0d]", i);
        $finish;
      end
    end
  endgenerate

  initial #2 $display("PASSED");
endmodule
