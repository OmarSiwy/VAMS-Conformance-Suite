//@ std 1364-2005
//! inherited IEEE 1364-2005 12.3.8
// A 32-bit output port connected to an 8-bit net truncates to the net
// (pr1752353).
module subbuf(output [31:0] out, input [31:0] in);
  assign out = ~in;
endmodule

module triage_port_output_width_truncates;
  reg [31:0] src;
  wire [7:0] tmp;

  subbuf u(.out(tmp), .in(src));

  initial begin
    src = 32'h11223344;
    #1;
    if (tmp === 8'hbb)
      $display("PASSED");
    else
      $display("FAILED %h", tmp);
  end
endmodule
