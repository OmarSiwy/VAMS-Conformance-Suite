// IEEE 1364-2005 §5.2.1: an indexed part-select has a positive constant
// width and a runtime integer base. "Part-selects that are partially out of
// range shall, when read, return x for the bits that are out of range";
// writes affect only existing bits. §5.5.1 makes every packed select unsigned.
//
// Both declarations hold a5. d[4 +:4] is its low nibble 5; a[4 +:4]
// is its high nibble a. Reversing the select direction at index 11 reverses
// those nibble choices. A whole signed byte extends to ffa5; its full-width
// select zero-extends to 00a5. Bases 2 and 10 straddle the declared ends:
// selected high/low nibbles become 01xx/xx10 according to significance.
// Partial writes of 1101 below d and beyond a change their low pair to 11
// (a7); writes of 0101 at their high ends change the high pair to 01 (65).
// Unknown/far bases read x and write nothing. A 70-bit all-one write at
// storage offset 60 in 130 bits sets bits 129:60 and leaves 59:0 zero.
// Reading four bits beyond that vector returns xxxx11, preserving the
// two valid top bits. Width-invalid neighbours are native_select_*_rejected.
//! inherited IEEE 1364-2005 5.2.1 5.5.1
// native-required
module native_indexed_selects;
  reg signed [11:4] d;
  reg signed [4:11] a;
  reg [15:0] whole, selected;
  reg [129:0] wide;
  integer b;
  initial begin
    d = 8'ha5; a = 8'ha5;
    b = 4;
    $display("up %h %h", d[b +: 4], a[b +: 4]);
    b = 11;
    $display("down %h %h", d[b -: 4], a[b -: 4]);
    b = 4; whole = d; selected = d[b +: 8];
    $display("sign %h %h", whole, selected);
    b = 2; $display("low %b %b", d[b +: 4], a[b +: 4]);
    b = 10; $display("high %b %b", d[b +: 4], a[b +: 4]);
    b = 2; d[b +: 4] = 4'b1101;
    b = 10; a[b +: 4] = 4'b1101;
    $display("low-write %h %h", d, a);
    d = 8'ha5; a = 8'ha5;
    b = 10; d[b +: 4] = 4'b0101;
    b = 2; a[b +: 4] = 4'b0101;
    $display("high-write %h %h", d, a);
    b = 32'bx;
    $display("unknown %b %b", d[b +: 4], a[b -: 4]);
    d[b +: 4] = 0; a[b -: 4] = 0;
    b = 100;
    $display("outside %b %b", d[b +: 4], a[b -: 4]);
    d[b +: 4] = 0; a[b -: 4] = 0;
    $display("unchanged %h %h", d, a);
    wide = 0; b = 60; wide[b +: 70] = {70{1'b1}};
    $display("wide %h %b", wide, wide[b +: 70] === {70{1'b1}});
    b = 128; $display("wide-end %b", wide[b +: 6]);
    b = 32'bz; $display("wide-z %b", wide[b -: 6]);
    $finish(0);
  end
endmodule
