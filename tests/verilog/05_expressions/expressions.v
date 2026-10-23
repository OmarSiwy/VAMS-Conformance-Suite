// IEEE1364-2005 §§5.4.2,5.4.3,5.5.1–5.5.3; no simulator-derived oracle.
//! inherited IEEE 1364-2005 5.1.5 5.1.11 5.1.13 5.4.1 5.4.2 5.4.3 5.5.1 5.5.2 5.5.3
module expressions;
  reg [15:0] a, b, answer;
  reg [3:0] p, q;
  reg [7:0] wide;
  reg [128:0] huge;
  reg signed [7:0] signed_dest;
  integer negative, count;
  initial begin
    a=16'hffff; b=16'h0001;
    answer=(a+b)>>1;
    $display("carry-truncated %b",answer);
    answer=(a+b+0)>>1;
    $display("carry-preserved %b",answer);
    p=4'hf; q=4'hf;
    wide=(p*q)+p;
    $display("wide-product %b",wide);
    $display("self-product %b",p*q);
    wide=-4'sd8;
    $display("signed-negate %b",wide);
    wide=(-4'sd8)+8'd0;
    $display("unsigned-negate %b",wide);
    signed_dest=4'b1111+4'b0001;
    $display("lhs-sign-independent %b",signed_dest);
    wide=(8'shff/8'sd2)+8'd0;
    $display("unsigned-division %b",wide);
    negative=-1; count=0;
    $display("compound-unsigned-compare %b",((negative>>count)+0)>32'h1);
    count=1;
    // IEEE4.8 permits native integers wider than32. Fix BOTH RHS widths so
    // unsigned comparison context yields 0x7fffffff after shifting, on every
    // permitted native integer width. The earlier native-integer operand and
    // unsized zero could instead yield a value above0x80000000 on wider hosts.
    // WIDTH-CONTEXT in docs/conformance-ieee-expression-width-review.md at 8b1514d4 tracks this
    // oracle correction; the required printed result remains1.
    $display("unsigned-arithmetic-shift %b",((32'shffffffff>>>count)+32'sd0)<32'h80000000);
    $display("signed-arithmetic-shift %b",((negative>>>count)+0)<32'sh80000000);
    wide=(4'hf+4'h1)==4'h0;
    $display("comparison-boundary %b",wide);
    wide=|(4'hf+4'h1);
    $display("reduction-boundary %b",wide);
    wide=(4'hf+4'h1)||1'b0;
    $display("logical-boundary %b",wide);
    wide=4'b1<<(2'b11+2'b01);
    $display("count-boundary %b",wide);
    wide=8'hff>>-2'sd1;
    $display("negative-count-bits %b",wide);
    wide=8'hff>>(65'd64+65'd1);
    $display("wide-count %b",wide);
    wide=1'b1 ? 4'sh8 : 8'h0;
    $display("conditional-common-type %b",wide);
    wide=(4'hf+4'h1) ? 8'hff : 8'h11;
    $display("conditional-condition %b",wide);
    $display("conditional-size %b",1'b1 ? (4'h9&4'h8) : 5'h0);
    $display("conditional-merge %b",1'bx ? (4'h3+4'h1) : (8'h80|8'h04));
    $display("legacy-z-merge %b",1'bz ? 4'bzz11 : 4'bzz11);
    $display("selected-z %b",1'b1 ? 4'bzz11 : 4'b0000);
    $display("known-one-condition %b",4'b1xxx ? 8'hff : 8'h00);
    $display("reductions %b %b %b %b %b %b", &4'b1111, ~&4'b1111, |4'b0000, ~|4'b0000, ^4'b1011, ~^4'b1011);
    $display("unknown-reductions %b %b %b", &4'b0xxx, |4'b1zzz, ^4'b01xz);
    $display("nested-case-equality %b", (1'bx ? 4'b1010 : 4'b1000)===4'b10x0);
    // Propagation crosses packed word boundaries before evaluating arithmetic.
    huge=(65'h1ffffffffffffffff+65'd1)>>1;
    $display("multiword-carry %b",huge);
    huge=(65'sh10000000000000000>>>1)+129'd0;
    $display("multiword-unsigned-shift %b",huge);
    huge=1'bx ? 65'bx : 129'd0;
    $display("multiword-unknown-padding %b",huge);
    wide=4'd3**4'd3;
    $display("power-context %b",wide);
    $display("power-self %b",4'd3**4'd3);
    $display("power-zero %b %b",8'd0**4'd0,8'd0**-4'sd1);
    $display("power-negative %b %b %b",8'd2**-4'sd1,8'shff**-4'sd1,8'shff**-4'sd2);
    answer=8'shfe**4'd3;
    $display("power-base-sign %b",answer);
    wide=8'd2**(2'b11+2'b01);
    $display("power-exponent-context %b",wide);
    $display("power-unknown %b %b",8'd1**1'bx,8'bzzzzzzzz**1'b0);
    $finish(0);
  end
endmodule
