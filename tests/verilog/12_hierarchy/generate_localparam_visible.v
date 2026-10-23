//! inherited IEEE 1364-2005 12.4.1
// A localparam declared in a generate-loop block is visible in that block,
// including a nested generate if (pr3534422).
module triage_generate_localparam_visible;
  reg [3:0] flags = 4'b0000;

  generate
    genvar i;
    for (i = 1; i < 4; i = i + 1) begin : loop
      localparam j = i;
      if (j > 0) begin
        initial #1 flags[j] = 1'b1;
      end
    end
  endgenerate

  initial begin
    #2;
    if (flags === 4'b1110)
      $display("PASSED");
    else
      $display("FAILED %b", flags);
  end
endmodule
