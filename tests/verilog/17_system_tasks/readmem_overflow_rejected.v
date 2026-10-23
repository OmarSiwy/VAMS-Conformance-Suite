// Historical filename retained; this is now a POSITIVE DIGITAL fixture.
// IEEE1364-2005 §17.2.9 printed297 requires a WARNING, not a load refusal,
// when word count differs from the requested range and no @ addresses occur.
// Five sequential words11,22,33,44,55 fill four locations with11,22,33,44.
// Loading stops at the highest location; the fifth word has no destination.
// The former rejection rule wrongly required an error. That claim is withdrawn
// to IEEE-FILE-MEM-002 in docs/conformance-ieee-fileio-review.md at 8b1514d4.
// The positive runner requires successful continuation, exact loaded data,
// and a warning diagnostic header matching both the code and specific phrase.
// These warning expectations are the new bounded implementation contract;
// the previous CLI loaded the data but silently omitted the required warning.
//! inherited IEEE 1364-2005 17.2.9
//! data 91_readmem_overflow_rejected.hex
`timescale 1ns/1ns
module d09_readmem_overflow;
  reg [7:0] m [0:3];
  initial begin
    $readmemh("91_readmem_overflow_rejected.hex", m, 0, 3);
    $display("%h %h %h %h", m[0], m[1], m[2], m[3]);
    $finish(0);
  end
endmodule
