// IEEE 1364-2005 §5.2.1: completely out-of-bounds selects read x and
// writes have no effect. A legal 64-bit base cannot overflow the host's
// address calculation. For [11:4], both signed endpoints are far outside;
// no part of an eight-bit select overlaps. Their bit-select neighbours
// are also outside. A base of 4 selects the whole a5 word afterward.
// Extreme declared bounds are legal integer constant expressions (§4.3.1):
// up's leftmost bit is at maxInt64-7 and its LSB at maxInt64. Therefore
// up[maxInt64 +:4] retains just its LSB, followed by three x bits (1xxx).
// down[minInt64 -:4] also places its sole in-range bit above three x bits
// (1xxx): the selected range's least-significant end is below the vector.
// The computation must subtract the declaration origin before adding width.
// An unsigned ffffffffffffffff is positive and out of bounds; it must not
// alias declared index -1. The signed value -1 does address neg[-1] and
// mem[-1]: neg[-1]=1, neg[-1 -:4]=a (a5's high nibble), and
// mem[-1][3:0]=c (3c's low nibble).
// These legal values require runtime behavior, not an invented rejection.
//! inherited IEEE 1364-2005 4.3.1 5.2.1 5.2.2
// native-required
module native_select_boundaries;
  reg [11:4] d;
  reg [64'sh7ffffffffffffff8:64'sh7fffffffffffffff] up;
  reg [64'sh8000000000000007:64'sh8000000000000000] down;
  reg signed [63:0] b;
  reg [63:0] u;
  reg [-1:-8] neg;
  reg [7:0] mem[-1:-2];
  initial begin
    d = 8'ha5; up = 8'ha5; down = 8'ha5;
    b = 64'sh8000000000000000;
    $display("min %b %b", d[b -: 8], d[b]);
    d[b -: 8] = 0;
    $display("decl-min %b", down[b -: 4]);
    b = 64'sh7fffffffffffffff;
    $display("max %b %b", d[b +: 8], d[b]);
    d[b +: 8] = 0;
    $display("decl-max %b", up[b +: 4]);
    b = 4; $display("kept %h", d[b +: 8]);
    neg = 8'ha5; mem[-1] = 8'h3c; mem[-2] = 0;
    u = 64'hffffffffffffffff;
    $display("unsigned %b %b %b", neg[u], neg[u -: 4], mem[u][3:0]);
    neg[u -: 4] = 0; mem[u][3:0] = 0;
    b = -1;
    $display("signed %b %h %h", neg[b], neg[b -: 4], mem[b][3:0]);
    $finish(0);
  end
endmodule
