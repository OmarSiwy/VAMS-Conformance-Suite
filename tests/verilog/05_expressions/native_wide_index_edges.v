// IEEE 1364-2005 §5.2.1 requires a partially out-of-range part-select to
// read x for missing bits and write only the bits within the declaration.
// The base may be outside the engine's signed 64-bit declaration range
// while the selection still overlaps it. No low-word truncation is valid.
//
// Every vector starts at a5 (10100101). A four-bit selection starts two
// indices beyond its end: the descending high and ascending low cases
// read xx10, the other two 01xx. Writing all ones changes only bits 7:6
// (e5) or 1:0 (a7). The NBA captures the old high base before it changes,
// then clears bits 7:6 of e5, giving 25. Constant bounds and widths may
// also be wide integer expressions. Invalid width neighbors are the
// native_select_{zero,variable}_width_rejected fixtures.
//! inherited IEEE 1364-2005 5.2.1 9.2.2
// native-required
module native_wide_index_edges;
  localparam signed [63:0] HI = 64'sh7fffffffffffffff;
  localparam signed [63:0] LO = 64'sh8000000000000000;
  reg [HI:HI-7] hi_down;
  reg [HI-7:HI] hi_up;
  reg [LO+7:LO] lo_down;
  reg [LO:LO+7] lo_up;
  reg [129:0] high_base;
  reg signed [129:0] low_base;
  initial begin
    hi_down = 8'ha5; hi_up = 8'ha5;
    lo_down = 8'ha5; lo_up = 8'ha5;
    high_base = 130'd9223372036854775809;
    low_base = -130'sd9223372036854775810;
    $display("edges %b %b %b %b", hi_down[high_base -: 4],
             hi_up[high_base -: 4], lo_down[low_base +: 4],
             lo_up[low_base +: 4]);
    hi_down[high_base -: 4] = 4'b1111;
    hi_up[high_base -: 4] = 4'b1111;
    lo_down[low_base +: 4] = 4'b1111;
    lo_up[low_base +: 4] = 4'b1111;
    $display("write %h %h %h %h", hi_down, hi_up, lo_down, lo_up);
    hi_down[high_base -: 4] <= 0;
    high_base = 0;
    #1 $display("nba %h", hi_down);
    $finish(0);
  end
endmodule
