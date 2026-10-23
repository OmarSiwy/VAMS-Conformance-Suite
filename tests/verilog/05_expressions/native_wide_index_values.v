// IEEE 1364-2005 §§5.2.1–5.2.2 use the numeric index value, not its bit
// width, to select storage. A 130-bit value of 4 addresses v[4]; 130 signed
// bits of -1 address m[-1]. High nonzero or unknown bits cannot be discarded
// to turn an invalid index into a valid low-word address.
//
// v=a5 gives v[4]=0 and v[4+:4]=a. Writing 3 to that nibble gives 35.
// m[-1]=96 gives m[-1][4+:4]=9; the analogous write of 6 gives 66.
// Constant wide indices then read 3. Positive 2^64+4, a magnitude beyond
// i128 and an index with unknown high bits read x and leave v unchanged.
// Their signed counterpart -1 remains a legal index, producing m[-1]=66.
// Zero/variable-width restrictions have named legal-neighbor rejections
// in native_select_{zero,variable}_width_rejected.v.
//! inherited IEEE 1364-2005 5.2.1 5.2.2
// native-required
module native_wide_index_values;
  reg [129:0] index;
  reg signed [129:0] address;
  reg [7:0] v, m[-1:-2];
  initial begin
    v = 8'ha5; m[-1] = 8'h96; m[-2] = 8'hff;
    index = 130'd4; address = -130'sd1;
    $display("positive %b %h", v[index], v[index +: 4]);
    v[index +: 4] = 4'h3;
    $display("negative %h", m[address][index +: 4]);
    m[address][index +: 4] = 4'h6;
    $display("writes %h %h %h %h", v, m[address],
             v[130'd4 +: 130'd4], v[130'd7:130'd4]);
    index = (130'd1 << 64) + 130'd4;
    $display("outside %b %b", v[index], v[index +: 4]);
    v[index +: 4] = 0;
    index = (130'd1 << 129) + 130'd4;
    address = -(130'sd1 << 128) - 130'sd1;
    $display("huge %b %b %h", v[index], v[index +: 4], m[address]);
    v[index +: 4] = 0;
    m[address] = 0;
    address = -130'sd1;
    index = {66'bx, 64'd4};
    $display("unknown %b %b", v[index], v[index +: 4]);
    v[index +: 4] = 0;
    $display("unchanged %h %h", v, m[address]);
    $finish(0);
  end
endmodule
