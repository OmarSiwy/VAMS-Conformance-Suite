//! inherited IEEE 1364-2005 7.8 7.1.5
// A pull gate may drive a bit-select of a vector net: pullup(bus[0]) and
// pullup(bus[1]) combine with the driver's (strong0,pull1) bufs to 10
// (br918c).
module driver(inout wire b0, inout wire b1);
  reg [1:0] v;

  buf (strong0, pull1) buf0(b0, v[0]);
  buf (strong0, pull1) buf1(b1, v[1]);

  initial v = 2'b10;
endmodule

module triage_pull_gate_bit_select;
  wire [1:0] bus;

  pullup pu0(bus[0]);
  pullup pu1(bus[1]);

  driver drv(.b0(bus[0]), .b1(bus[1]));

  initial begin
    #1;
    if (bus === 2'b10) $display("PASSED"); else $display("FAILED %b", bus);
  end
endmodule
