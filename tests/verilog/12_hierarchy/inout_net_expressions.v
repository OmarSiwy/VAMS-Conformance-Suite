//! inherited IEEE 1364-2005 12.3.6 12.3.9
// An inout port connects to any net expression: bit-select, part-select or
// concatenation (br965/inout2/inout3/tri2).
module bidir2(inout [1:0] p, input [1:0] d, input en);
  assign p = en ? d : 2'bzz;
endmodule

module bidir1(inout p, input d, input en);
  assign p = en ? d : 1'bz;
endmodule

module triage_inout_net_expressions;
  wire [3:0] bus;
  wire qh;
  wire [1:0] q;
  wire [1:0] pair;
  reg [1:0] d;
  reg en;

  bidir2 u_part(.p(bus[3:2]), .d(d), .en(en));
  bidir2 u_concat(.p({qh, q[0]}), .d(d), .en(en));
  bidir1 u_bit(.p(pair[0]), .d(d[0]), .en(en));

  initial begin
    en = 1'b1;
    d = 2'b10;
    #1;
    if (bus[3:2] === 2'b10 && bus[1:0] === 2'bzz &&
        qh === 1'b1 && q[0] === 1'b0 &&
        pair[0] === 1'b0 && pair[1] === 1'bz)
      $display("PASSED");
    else
      $display("FAILED %b %b %b %b %b", bus, qh, q[0], pair[0], pair[1]);
  end
endmodule
