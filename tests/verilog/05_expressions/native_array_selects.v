// IEEE 1364-2005 §5.2.2: each dimension selects one word, after which
// §5.2.1 packed select rules apply. Signed words retain their sign, but
// packed selects are unsigned (§5.5.1). Unknown/out-of-bounds addresses
// read x and cannot write a word. Invalid partial addresses are covered by
// partial_address_rejected.v; the legal neighbour supplies both.
//
// m[2][-1] starts at a5: low nibble 5, bit 2 = 1, bits 5:2 = 9.
// Replacing the top nibble by b, clearing bit 2, then writing bits 5:2
// with 6 gives b5, b1, 99. The concatenation writes its high nibble 3
// into that word's high nibble (39), and e into asc[1][2:5] (38).
// The delayed NBA captures m[2][-1] and base 2 now (§9.2.2); changing the
// indices cannot redirect it. Replacing bits 5:2 by a yields 29, while
// m[1][0] stays 3c. Array and packed unknown writes leave both unchanged.
// A wide element's write crosses the 64-bit storage boundary, yet only
// bank[1]'s bits 71:60 receive abc; bank[0] stays zero.
//! inherited IEEE 1364-2005 5.2.1 5.2.2 5.5.1 9.2.2
// native-required
`timescale 1ns/1ns
module native_array_selects;
  reg signed [7:0] m[2:1][-1:0];
  reg [0:7] asc[0:1];
  reg [129:0] bank[0:1];
  reg [15:0] whole, selected;
  integer i, j, b;
  initial begin
    m[2][-1] = 8'ha5; m[1][0] = 8'h3c;
    asc[1] = 0; bank[0] = 0; bank[1] = 0;
    i = 2; j = -1; b = 2;
    $display("read %h %b %h", m[i][j][3:0], m[i][j][b], m[i][j][b +: 4]);
    whole = m[i][j]; selected = m[i][j][0 +: 8];
    $display("sign %h %h", whole, selected);
    m[i][j][7:4] = 4'hb; m[i][j][b] = 0; m[i][j][b +: 4] = 4'h6;
    $display("write %h", m[2][-1]);
    {m[i][j][7 -: 4], asc[1][b +: 4]} = 8'h3e;
    $display("concat %h %h", m[2][-1], asc[1]);
    m[i][j][b +: 4] <= #2 4'ha;
    i = 1; j = 0; b = 0;
    #3 $display("nba %h %h", m[2][-1], m[1][0]);
    i = 3; $display("outside %b", m[i][0][0 +: 4]);
    m[i][0][0 +: 4] = 0;
    i = 32'bx; $display("unknown-word %b", m[i][0][3:0]);
    m[i][0][3:0] = 0;
    i = 1; b = 32'bz; m[i][0][b +: 4] = 0;
    $display("unchanged %h %h", m[2][-1], m[1][0]);
    b = 60; bank[i][b +: 12] = 12'habc;
    $display("wide %h %b", bank[i][71:60], bank[0] === 130'd0);
    $finish(0);
  end
endmodule
