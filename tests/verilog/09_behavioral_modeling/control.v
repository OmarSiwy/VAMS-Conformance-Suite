// IEEE1364-2005 §§9.4–9.6. Expected values follow four-state control rules.
//! inherited IEEE 1364-2005 9.4 9.5 9.5.1 9.6
`timescale 1ns/1ns
module control;
  reg [3:0] i, j, count, value, a, b;
  initial begin
    if (2'b1x) $display("if-known-one"); else $display("BAD");
    if (2'b0x) $display("BAD"); else $display("if-unknown-else");
    if (1'bz) $display("BAD"); else $display("if-z-else");
    if (1) if (0) $display("BAD"); else $display("closest-else");
    case (2'bxz)
      default: $display("BAD");
      2'bzz: $display("BAD");
      2'bxz: $display("case-exact-first");
      2'bxz: $display("BAD");
    endcase
    casez (4'bz100)
      4'b0100: $display("casez-selector-wildcard");
      default: $display("BAD");
    endcase
    casez (4'bx100)
      4'b0100: $display("BAD");
      4'bx100: $display("casez-x-exact");
    endcase
    casex (4'bx100)
      4'b0000,4'b0100: $display("casex-label-list");
      4'bx100: $display("BAD");
    endcase
    casez (4'b1010)
      4'b1?1?: $display("casez-label-priority");
      4'b1010: $display("BAD");
    endcase
    case (4'shf)
      8'shff: $display("BAD");
      8'h00: $display("BAD");
      8'h0f: $display("case-global-signedness");
    endcase
    case (4'hf+4'h1)
      4'h0: $display("BAD");
      8'h10: $display("case-global-width");
    endcase
    case (4'sb1000>>>1)
      8'shfc: $display("BAD");
      8'h04: $display("case-nested-context");
    endcase
    case (1) 2: $display("BAD"); endcase
    case (1) default: $display("case-default"); 2: $display("BAD"); endcase
    a=0; b=0;
    for (i=0; i<3; i=i+1) begin
      value=i;
      b<=value;
      value=4'hf;
      a<=i;
      a<=i+1;
      #0 $display("for-inactive %b %b",i,a);
      #1 $display("for-nba %b %b %b",i,a,b);
    end
    while (i>0) begin
      #1 i=i-1;
      $display("while-resume %b",i);
    end
    count=3; j=0;
    repeat (count) begin
      count=0;
      repeat (2) begin #1 j=j+1; end
      $display("repeat-captured %b",j);
    end
    repeat (1'bx) $display("BAD");
    repeat (1'bz) $display("BAD");
    repeat (0) $display("BAD");
    while (1'bx) $display("BAD");
    for (i=1; 1'bx; i=i+1) $display("BAD");
    $display("for-unknown %b",i);
    i=0;
    while (1) begin
      i=i+1;
      if (i==3) begin $display("finish-loop %b",i); $finish(0); end
    end
    $display("BAD");
  end
endmodule
